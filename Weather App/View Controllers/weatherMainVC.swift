//
//  weatherMainVC.swift
//  Weather App
//
//  Created by Bilal on 10/03/25.
//

import UIKit
import SVProgressHUD
import CoreLocation

class weatherMainVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,DataPassingDelegate
{
    //MARK: - Outlets

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchTableViewHeight: NSLayoutConstraint!
    
    //MARK: - Variables

    var temprature : String?
    var place: String?
    var min_temp : String?
    var max_temp : String?
    var timeZone : String?
    var weather : String?
    var searchDataArr : [SearchResonse] = []
    var receiveAddedDataArr : [WeatherResponse] = []
    let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradient()
        setUpUI()
        locationManager.onLocationUpdate = { latitude, longitude in
            print("Current Latitude: \(latitude), Current Longitude: \(longitude)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        txtSearch.text = ""
        let fetchdata = fetchWeatherDataFromCoreData()
        print("Fetching weather data is :- \(fetchdata)")
        receiveAddedDataArr = fetchWeatherDataFromCoreData()
        print("new received data \(receiveAddedDataArr)")
        searchTableView.isHidden = true
        if receiveAddedDataArr.count == 0{
            self.getCityName(latitude: "23.02579N", longitude: "72.58727E") { city in
                print("City Name: \(city ?? "")")
            }
        }else {
            self.getCityName(latitude: receiveAddedDataArr[0].lat ?? "", longitude: receiveAddedDataArr[0].lon ?? "") { city in
                //                self.location = city
                print("City Name: \(city ?? "")")
                self.weatherAPICall()
            }
            print("Received Lat is :- \(receiveAddedDataArr[0].lat ?? "")")
            print("Received Lon is :- \(receiveAddedDataArr[0].lon ?? "")")
        }
    }
    
    //MARK: - UI Setup
    
    func applyGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bgView.bounds
        
        let increasedHeight: CGFloat = bgView.bounds.height * 2 // Add extra height
        let increasedwidth: CGFloat = bgView.bounds.width + 20
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: increasedwidth, height: increasedHeight)
        
        // Set gradient colors
        gradientLayer.colors = [
            UIColor.init(hex: "535287").cgColor,
            UIColor.white.cgColor
        ]
        
        // Set gradient start and end points for top-right to bottom-left
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.3)   // Bottom-left
        
        bgView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setUpUI(){
        searchView.layer.cornerRadius = 25

        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.layer.cornerRadius = 20
        searchTableView.isHidden = true
        searchTableView.rowHeight = UITableView.automaticDimension
        searchTableView.estimatedRowHeight = 67

        txtSearch.attributedPlaceholder = NSAttributedString(
            string: "Enter Location",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        txtSearch.delegate = self
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        tableView.delegate = self
        tableView.dataSource = self
    }

    //MARK: - TextField Callback Methods
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count ?? 0 >= 3 {
            searchTableView.isHidden = false
            searchAPICall()
        }else {
            searchTableView.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hides the keyboard
        return true
    }
    
    //MARK: - Fahrenheit to Celcius And City Name Functions

    func convertToCelsius(fahrenheit: Int) -> Int {
        return (fahrenheit - 32) * 5 / 9
    }
    
    func convertStringToDouble(_ coordinate: String) -> Double? {
        var value = coordinate
        var multiplier = 1.0
        
        if coordinate.hasSuffix("S") || coordinate.hasSuffix("W") {
            multiplier = -1.0
        }
        
        value.removeLast() // Remove last character (N, S, E, W)
        
        if let doubleValue = Double(value) {
            return doubleValue * multiplier
        }
        return nil
    }
    
    func getCityName(latitude: String, longitude: String, completion: @escaping (String?) -> Void) {
        // Convert String to Double by removing N/S/E/W
        guard let latDouble = convertStringToDouble(latitude),
              let lonDouble = convertStringToDouble(longitude) else {
            print("Invalid latitude or longitude format")
            completion(nil)
            return
        }
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latDouble, longitude: lonDouble)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error getting city: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            
            if let placemark = placemarks?.first, let city = placemark.locality {
                completion(city)
            } else {
                completion(nil)
            }
        }
    }
    
    //MARK: - API Call

    func weatherAPICall(){
        let dispatchGroup = DispatchGroup()
        SVProgressHUD.show(withStatus: "Loading...")
        
        dispatchGroup.enter()
        WeatherService.shared.fetchWeather(longitude: receiveAddedDataArr[0].lon ?? "72.58727E", latitude: receiveAddedDataArr[0].lat ?? "23.02579N", timeZone: "asia/kolkata") { result in
            switch result {
            case .success(let weatherData):
                print("Weather: \(weatherData.current?.summary ?? "No data")")
                // self.weather = weatherData.current?.summary
                self.timeZone = weatherData.timezone
                if let tempFahrenheit = weatherData.current?.temperature, let minTempFahrenheit =  weatherData.daily?.data?[0].all_day?.temperature_min, let maxTempFahrenheit =  weatherData.daily?.data?[0].all_day?.temperature_max {
                    let tempCelsius = self.convertToCelsius(fahrenheit: Int(tempFahrenheit))
                    let minTempCelsius = self.convertToCelsius(fahrenheit: Int(minTempFahrenheit))
                    let maxTempCelsius = self.convertToCelsius(fahrenheit: Int(maxTempFahrenheit))
                    print("Temperature: \(tempCelsius)°C")
                    print("Min Temperature: \(minTempCelsius)°C")
                    print("max Temperature: \(maxTempCelsius)°C")
                    self.temprature = String("\(tempCelsius)°")
                    self.min_temp = String("\(minTempCelsius)°")
                    self.max_temp = String("\(maxTempCelsius)°")
                } else {
                    print("Temperature data not available")
                }
                self.getCityName(latitude: "23.02579N", longitude: "72.58727E"){ city in
                    //                    self.location = city
                }
                
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
    
    func searchAPICall(){
        let dispatchGroup = DispatchGroup()
        SVProgressHUD.show(withStatus: "Loading...")
        
        dispatchGroup.enter()
        WeatherService.shared.searchPlace(text: txtSearch.text ?? "") { result in
            switch result{
            case .success(let searchData):
                print(searchData)
                self.searchDataArr = searchData
                DispatchQueue.main.async {
                    self.searchTableView.reloadData()
                    self.updateTableViewHeight()
                }
            case .failure(let error):
                print(error)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: - Tableview Delegate methods
    
    func updateTableViewHeight() {
        let maxHeight: CGFloat = 300
        let contentHeight = searchTableView.contentSize.height
        
        searchTableViewHeight.constant = min(contentHeight, maxHeight)
        searchTableView.isScrollEnabled = contentHeight > maxHeight
        self.view.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView{
            return searchDataArr.count
        }else {
            return receiveAddedDataArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == searchTableView{
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! searchCell
            cell.lblCity.text = searchDataArr[indexPath.row].place_id
            cell.lblCountry.text = searchDataArr[indexPath.row].country
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! weatherDataCell
            print("receive data is :- \(receiveAddedDataArr)")
            print("receive data [indexPath.row] is :- \(receiveAddedDataArr[indexPath.row])")
            getCityName(latitude: self.receiveAddedDataArr[indexPath.row].lat ?? "", longitude: self.receiveAddedDataArr[indexPath.row].lon ?? "") { city in
                //self.location = city
                cell.lblLocation.text = city
            }
            weather = receiveAddedDataArr[indexPath.row].current?.summary
            
            if let tempFahrenheit = receiveAddedDataArr[indexPath.row].current?.temperature, let minTempFahrenheit =  receiveAddedDataArr[indexPath.row].daily?.data?[0].all_day?.temperature_min, let maxTempFahrenheit =  receiveAddedDataArr[indexPath.row].daily?.data?[0].all_day?.temperature_max {
                let tempCelsius = self.convertToCelsius(fahrenheit: Int(tempFahrenheit))
                let minTempCelsius = self.convertToCelsius(fahrenheit: Int(minTempFahrenheit))
                let maxTempCelsius = self.convertToCelsius(fahrenheit: Int(maxTempFahrenheit))
                print("Temperature: \(tempCelsius)°C")
                print("Min Temperature: \(minTempCelsius)°C")
                print("Max Temperature: \(maxTempCelsius)°C")
                
                self.min_temp = String("\(minTempCelsius)°")
                self.max_temp = String("\(maxTempCelsius)°")
                
                cell.lblTemprature.text = String("\(tempCelsius)°")
                
                if weather == "Sunny" || weather == "Mostly sunny"{
                    cell.lblMinMaxTemp.text = "🌤️ \(weather ?? "")   \(min_temp ?? "0.0")/\(max_temp ?? "0.0")"
                }else if weather == "Clear" || weather == "Partly clear" || weather == "Mostly clear"{
                    cell.lblMinMaxTemp.text = "☀️ \(weather ?? "")   \(min_temp ?? "0.0")/\(max_temp ?? "0.0")"
                }else if weather == "Partly_sunny"{
                    cell.lblMinMaxTemp.text = "⛅ \(weather ?? "")   \(min_temp ?? "0.0")/\(max_temp ?? "0.0")"
                }else if weather == "Overcast"{
                    cell.lblMinMaxTemp.text = "☁️ \(weather ?? "")   \(min_temp ?? "0.0")/\(max_temp ?? "0.0")"
                }else if weather == "Rain" || weather == "Light rain"{
                    cell.lblMinMaxTemp.text = "🌧 \(weather ?? "")   \(min_temp ?? "0.0")/\(max_temp ?? "0.0")"
                }else if weather == "Cloudy" || weather == "Mostly cloudy"{
                    cell.lblMinMaxTemp.text = "☁️ \(weather ?? "")   \(min_temp ?? "0.0")/\(max_temp ?? "0.0")"
                }else {
                    cell.lblMinMaxTemp.text = "☀️ \(weather ?? "")   \(min_temp ?? "0.0")/\(max_temp ?? "0.0")"
                }
            } else {
                print("Temperature data not available")
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchTableView{
            let vc = storyboard?.instantiateViewController(withIdentifier: "weatherDetailVC") as! weatherDetailVC
            vc.location = searchDataArr[indexPath.row].place_id
            vc.timeZone = searchDataArr[indexPath.row].timezone
            vc.longitude = searchDataArr[indexPath.row].lon
            vc.latitude = searchDataArr[indexPath.row].lat
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "weatherDetailVC") as! weatherDetailVC
            getCityName(latitude: self.receiveAddedDataArr[indexPath.row].lat ?? "",
                        longitude: self.receiveAddedDataArr[indexPath.row].lon ?? "") { city in
                DispatchQueue.main.async {
                    vc.location = city
                    vc.min_temp = self.min_temp
                    vc.max_temp = self.max_temp
                    vc.timeZone = self.timeZone
                    vc.longitude = self.receiveAddedDataArr[indexPath.row].lon
                    vc.latitude = self.receiveAddedDataArr[indexPath.row].lat
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if tableView != searchTableView{
            if editingStyle == .delete {
                deleteWeatherData(at: indexPath, WeatherData: receiveAddedDataArr)
                receiveAddedDataArr.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    //MARK: - Custom Delegate Methods

    func appendData(data: [WeatherResponse]) {
        self.receiveAddedDataArr.insert(contentsOf: data, at: 0) // Insert at the top
        
        print("Received Data :- \(data)")
        print("Received Data Array :- \(receiveAddedDataArr)")
        saveWeatherData(weather: self.receiveAddedDataArr)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()// Refresh the table view
        }
    }
}
