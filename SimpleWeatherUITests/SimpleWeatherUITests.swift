//
//  SimpleWeatherUITests.swift
//  SimpleWeatherUITests
//
//  Created by Sasha Goldshtein on 11/29/16.
//  Copyright © 2016 Sasha Goldshtein. All rights reserved.
//

import XCTest
import SBTUITestTunnel

class SimpleWeatherUITests: XCTestCase {
    
    private var app: SBTUITunneledApplication!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        app = SBTUITunneledApplication()
        let launchOptions = [
            SBTUITunneledApplicationLaunchOptionResetFilesystem,
            SBTUITunneledApplicationLaunchOptionDisableUITextFieldAutocomplete
        ]
        app.launchTunnel(withOptions: launchOptions) {
            // Perform initialization within the context of the test application if needed
        }
        app.monitorRequests(matching: SBTRequestMatch.url("api.openweathermap.org"))
        sleep(1)    // Yes, UI tests are flaky like that
    }
    
    private func enterCityAndTapGetWeather(city: String?) {
        let field = app.textFields["city"]
        field.buttons["Clear text"].tap()
        if let city = city {
            field.typeText(city)
        }
        let getButton = app.buttons["Get Weather!"]
        getButton.tap()
        sleep(1)
    }
    
    func testGetWeatherWithNoCity() {
        enterCityAndTapGetWeather(city: nil)
        
        let requests = app.monitoredRequestsFlushAll()
        XCTAssertEqual(0, requests.count)
        
        let table = app.tables["results"]
        XCTAssertEqual(0, table.cells.count)
    }
    
    func testGetWeatherWithCity() {
        let responseDictionary: [String: NSObject] = [
            "weather": NSArray(array: [[ "description": "mist" ]]),
            "main": NSDictionary(dictionary: ["temp": 268.83, "humidity": 92])
            ]
        
        app.stubRequests(matching: SBTRequestMatch.url("api.openweathermap.org"),
                         returnJsonDictionary: responseDictionary,
                         returnCode: 200,
                         responseTime: 0.2)
        
        enterCityAndTapGetWeather(city: "Tel Aviv")
        
        let requests = app.monitoredRequestsFlushAll()
        XCTAssertEqual(1, requests.count)
        let request = requests[0]
        guard let url = request.request?.url?.absoluteString else {
            XCTFail("Request URL is missing")
            return
        }
        XCTAssertEqual("http://api.openweathermap.org/data/2.5/weather?q=Tel%20Aviv&appid=51174bce8f4a02feb1551c3b7485e95a", url)
        
        let cells = app.tables.cells
        XCTAssertEqual(1, cells.count)
        XCTAssertTrue(cells.staticTexts["Mist in Tel Aviv"].exists)
        XCTAssertTrue(cells.staticTexts["-4.32℃, 92% humidity"].exists)
    }
    
    func testGetWeatherInvalidResponse() {
        app.stubRequests(matching: SBTRequestMatch.url("api.openweathermap.org"),
                         returnJsonDictionary: [:],     // Empty invalid dictionary
                         returnCode: 200,
                         responseTime: 0.2)
        
        enterCityAndTapGetWeather(city: "Tel Aviv")
        
        XCTAssertTrue(app.alerts["Error"].exists)
        app.alerts["Error"].buttons["Dismiss"].tap()
        
        let cells = app.tables.cells
        XCTAssertEqual(1, cells.count)
        XCTAssertTrue(cells.staticTexts["Error"].exists)
    }
    
    func testGetWeatherWithActualServer() {
        enterCityAndTapGetWeather(city: "Tel Aviv")
        
        let cells = app.tables.cells
        XCTAssertEqual(1, cells.count)
        XCTAssertFalse(cells.staticTexts["Error"].exists)
    }
    
}
