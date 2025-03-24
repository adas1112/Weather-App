//
//  weatherDetailVC.swift
//  Weather App
//
//  Created by Bilal on 11/03/25.
//

import UIKit
import SVProgressHUD

class weatherDetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate {
    
    //MARK: - Outlets

    @IBOutlet weak var lblWind: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var aqiView: UIView!
    @IBOutlet weak var forecastView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblMinMaxTemp: UILabel!
    
    //MARK: - Variables

    var location : String?
    var longitude : String?
    var latitude : String?
    var min_temp : String?
    var max_temp : String?
    var timeZone : String?
    var weatherDataArr : [WeatherResponse] = []
    var forecastDataArr : [DataWeather] = []
    var addDataArr : [WeatherResponse] = []
    weak var delegate: DataPassingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        randomImageGenerate()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        apiCall()
    }
    
    //MARK: - SetUp UI
    
    func setUpUI(){
        tableView.delegate = self
        tableView.dataSource = self

        aqiView.layer.cornerRadius = 25
        forecastView.layer.cornerRadius = 30
        
        lblLocation.text = location
    }
        
    //MARK: - Button Click Action

    @IBAction func addBtnClick(_ sender: Any) {
        delegate?.appendData(data: weatherDataArr) // Send data back
        navigationController?.popViewController(animated: true) // Go back
    }
    
    //MARK: - Random Image Generation Functions

    func getRandomNumber() -> Int {
        return Int.random(in: 1...5)
    }
    
    func randomImageGenerate(){
        let randomNum = getRandomNumber()
        if randomNum == 1{
            bgImageView.image = UIImage(named: "image2")
        }else if randomNum == 2{
            bgImageView.image = UIImage(named: "image1")
        }else if randomNum == 3{
            bgImageView.image = UIImage(named: "image3")
        }else if randomNum == 4{
            bgImageView.image = UIImage(named: "image4")
        }else {
            bgImageView.image = UIImage(named: "image5")
        }
    }
    
    //MARK: - Convert Fahrenheit to Celcius Function

    func convertToCelsius(fahrenheit: Int) -> Int {
        return (fahrenheit - 32) * 5 / 9
    }
    
    //MARK: - API Calling
    
    func apiCall(){
        let dispatchGroup = DispatchGroup()
        SVProgressHUD.show(withStatus: "Loading...")
        
        dispatchGroup.enter()
        WeatherService.shared.fetchWeather(longitude: longitude ?? "", latitude: latitude ?? "",timeZone: timeZone ?? "asia/kolkata") { result in
            switch result {
            case .success(let weatherData):
                self.lblWind.text = "🌿 Wind \(weatherData.current?.wind?.speed ?? 0.0)"
                print("Weather: \(weatherData.current?.summary ?? "No data")")
                if let tempFahrenheit = weatherData.current?.temperature, let minTempFahrenheit =  weatherData.daily?.data?[0].all_day?.temperature_min, let maxTempFahrenheit =  weatherData.daily?.data?[0].all_day?.temperature_max {
                    let tempCelsius = self.convertToCelsius(fahrenheit: Int(tempFahrenheit))
                    let minTempCelsius = self.convertToCelsius(fahrenheit: Int(minTempFahrenheit))
                    let maxTempCelsius = self.convertToCelsius(fahrenheit: Int(maxTempFahrenheit))
                    print("Temperature is: \(tempCelsius)°C")
                    print("Min Temperature: \(minTempCelsius)°C")
                    print("max Temperature: \(maxTempCelsius)°C")
                    self.lblTemp.text = String("\(tempCelsius)°")
                    self.min_temp = String("\(minTempCelsius)°")
                    self.max_temp = String("\(maxTempCelsius)°")
                    self.lblMinMaxTemp.text = "\(weatherData.current?.summary ?? "") \(minTempCelsius)° / \(maxTempCelsius)°"
                } else {
                    print("Temperature data not available")
                }
                self.forecastDataArr = weatherData.daily?.data ?? []
                self.weatherDataArr.append(weatherData)
                print(self.forecastDataArr)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching weather data: \(error.localizedDescription)")
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: - TableView Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:  indexPath) as! forecastDataCell
        if let minTempFahrenheit = forecastDataArr[indexPath.row].all_day?.temperature_min, let maxTempFahrenheit = forecastDataArr[indexPath.row].all_day?.temperature_max{
            let minTempCelsius = self.convertToCelsius(fahrenheit: Int(minTempFahrenheit))
            let maxTempCelsius = self.convertToCelsius(fahrenheit: Int(maxTempFahrenheit))
            self.min_temp = String("\(minTempCelsius)°")
            self.max_temp = String("\(maxTempCelsius)°")
        }else {
            
        }
        
        if forecastDataArr[indexPath.row].all_day?.weather == "sunny" || forecastDataArr[indexPath.row].all_day?.weather == "mostly sunny"{
            cell.lblDate.text = "🌤️ \(forecastDataArr[indexPath.row].day ?? "")"
        }else if forecastDataArr[indexPath.row].all_day?.weather == "clear"{
            cell.lblDate.text = "☀️ \(forecastDataArr[indexPath.row].day ?? "")"
        }else if forecastDataArr[indexPath.row].all_day?.weather == "partly_sunny"{
            cell.lblDate.text = "⛅ \(forecastDataArr[indexPath.row].day ?? "")"
        }else if forecastDataArr[indexPath.row].all_day?.weather == "overcast"{
            cell.lblDate.text = "☁️ \(forecastDataArr[indexPath.row].day ?? "")"
        }else if forecastDataArr[indexPath.row].all_day?.weather == "rain"{
            cell.lblDate.text = "🌧 \(forecastDataArr[indexPath.row].day ?? "")"
        }else {
            cell.lblDate.text = "☀️ \(forecastDataArr[indexPath.row].day ?? "")"
        }
        cell.lblMinMaxTemp.text = "\(min_temp ?? "") / \(max_temp ?? "")"
        return cell
    }
}
