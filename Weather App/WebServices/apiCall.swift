//
//  apiCall.swift
//  Weather App
//
//  Created by Bilal on 11/03/25.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    
    private let apiKey = "sind2q8cd6qgiso9xuhuzij3mzt7lx1fsrdj5pur"  
    private let baseURL = "https://www.meteosource.com/api/v1/free/"
    
    func fetchWeather(longitude: String,latitude: String,timeZone : String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/point?place_id=&lat=\(latitude)&lon=\(longitude)&sections=current,hourly,daily&timezone=&language=en&units=us&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 404, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(weatherResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    
    func searchPlace(text: String, completion: @escaping (Result<[SearchResonse], Error>) -> Void) {
        let urlString = "\(baseURL)/find_places_prefix?text=\(text)&language=en&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 404, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode([SearchResonse].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(searchResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}



