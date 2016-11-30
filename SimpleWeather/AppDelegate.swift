//
//  AppDelegate.swift
//  SimpleWeather
//
//  Created by Sasha Goldshtein on 11/29/16.
//  Copyright © 2016 Sasha Goldshtein. All rights reserved.
//

import UIKit
import SBTUITestTunnel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override class func initialize() {
        #if DEBUG
            SBTUITestTunnelServer.takeOff()
        #endif
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

}

