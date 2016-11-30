//
//  AppUserDefaults.swift
//  SimpleWeather
//
//  Created by Sasha Goldshtein on 11/30/16.
//  Copyright © 2016 Sasha Goldshtein. All rights reserved.
//

import Foundation

fileprivate let LAST_CITY_KEY = "net.sashag.simple_weather.last_city"

class AppUserDefaults {

    func lastCity() -> String? {
        return UserDefaults.standard.string(forKey: LAST_CITY_KEY)
    }
    
    func saveLastCity(_ city: String) {
        UserDefaults.standard.setValue(city, forKey: LAST_CITY_KEY)
        UserDefaults.standard.synchronize()
    }
    
}
