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
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        let app = SBTUITunneledApplication()
        let launchOptions = [
            SBTUITunneledApplicationLaunchOptionResetFilesystem,
            SBTUITunneledApplicationLaunchOptionDisableUITextFieldAutocomplete
        ]
        app.launchTunnel(withOptions: launchOptions) {
            // TODO
        }
    }
    
    func testGetWeatherWithNoCity() {
        
    }
    
}
