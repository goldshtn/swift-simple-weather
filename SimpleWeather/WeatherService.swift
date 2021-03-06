//
//  WeatherService.swift
//  SimpleWeather
//
//  Created by Sasha Goldshtein on 11/30/16.
//  Copyright © 2016 Sasha Goldshtein. All rights reserved.
//

import Foundation

struct WeatherConditions {
    var city: String
    var temperatureCelsius: Double
    var humidityPercent: Int
    var generalDescription: String
}

enum WeatherResult {
    case Success(WeatherConditions)
    case Error(String)
}

fileprivate let API_KEY = "51174bce8f4a02feb1551c3b7485e95a"
fileprivate let BASE_URL = "http://api.openweathermap.org/data/2.5/weather"

class WeatherService {
    
    func weather(forCity city: String, completionHandler: @escaping (WeatherResult) -> Void) {
        let escapedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: "\(BASE_URL)?q=\(escapedCity)&appid=\(API_KEY)")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completionHandler(.Error(error.localizedDescription))
                return
            }
            guard let data = data else {
                completionHandler(.Error("No data received"))
                return
            }
            completionHandler(self.weather(forCity: city, fromJsonData: data))
        }
        task.resume()
    }
    
    func weather(forCity city: String, fromJsonData data: Data) -> WeatherResult {
        let raw = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let json = raw as? [String: AnyObject],
              let weather = json["weather"] as? [AnyObject],
              let descriptionObj = weather[0] as? [String: AnyObject],
              let description = descriptionObj["description"] as? String,
              let main = json["main"],
              let temperature = main["temp"] as? Double,
              let humidity = main["humidity"] as? Int
        else {
            return .Error("Malformed JSON response")
        }
        func celsiusFromKelvin(kelvin: Double) -> Double {
            return kelvin - 273.15
        }
        return .Success(WeatherConditions(city: city,
                                          temperatureCelsius: celsiusFromKelvin(kelvin: temperature),
                                          humidityPercent: humidity,
                                          generalDescription: description))
    }
    
}
