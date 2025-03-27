//
//  WeatherService.swift
//  Horizon
//
//  Created by Vijay Venkatesan on 3/25/25.
//

//
//  WeatherService.swift
//  Horizon
//
//  Created by Vijay Venkatesan on 3/25/25.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct ForecastData: Codable {
    let list: [Forecast]
}

// Model for each 3-hour forecast entry
struct Forecast: Codable {
    let dt_txt: String // Date and time as a string
    let main: Main
    let weather: [Weather]
}



class WeatherService {
    let apiKey = "9f2ab64953e36216df4e532d138ec33d"
    
    func fetchWeather(for city: String, completion: @escaping (WeatherData?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=imperial"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let weatherResponse = try JSONDecoder().decode(WeatherData.self, from: data)
                    DispatchQueue.main.async {
                        completion(weatherResponse)
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}

extension WeatherService {
    func fetchForecast(for city: String, completion: @escaping ([Forecast]?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=imperial"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let forecastResponse = try JSONDecoder().decode(ForecastData.self, from: data)
                    DispatchQueue.main.async {
                        completion(forecastResponse.list) // Return only the forecast list
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
