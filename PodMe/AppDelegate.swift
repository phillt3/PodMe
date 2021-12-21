//
//  AppDelegate.swift
//  PodMe
//
//  Created by Phillip  Tracy on 10/31/21.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        if #available(iOS 15.0, *) {
//                    let navigationBarAppearance = UINavigationBarAppearance()
//                    navigationBarAppearance.configureWithDefaultBackground()
//                    //navigationBarAppearance.backgroundColor = uicolorFromHex(rgbValue: 0x8a100b)
//                    UINavigationBar.appearance().standardAppearance = navigationBarAppearance
//                    UINavigationBar.appearance().compactAppearance = navigationBarAppearance
//                    UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
//                }
        FirebaseApp.configure()
        return true
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
            let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
            let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
            let blue = CGFloat(rgbValue & 0xFF)/256.0

            return UIColor(red:red, green:green, blue:blue, alpha:1.0)
        }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    



}

