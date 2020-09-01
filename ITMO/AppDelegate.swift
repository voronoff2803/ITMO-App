//
//  AppDelegate.swift
//  ITMO
//
//  Created by Alexey Voronov on 15/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        // проверка режима интерфейса
        if #available(iOS 12.0, *), window?.rootViewController?.traitCollection.userInterfaceStyle == .dark {
            Config.changeToBlack()
        }
        
        self.getServerIP()
        
        self.getWeekEven()
        
        return true
    }
    
    // сохранение токена и информации о пользователе в firebase
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        DataFlowManager.shared.notificationToken = token
        if DataFlowManager.shared.login != "" && DataFlowManager.shared.password != "" {
            let tokenRef = Database.database().reference(withPath: "tokens")
            tokenRef.updateChildValues([DataFlowManager.shared.login : [DataFlowManager.shared.password, token]])
        }
    }
    
    func getServerIP() {
        let cdeURLRef = Database.database().reference(withPath: "/config")
        cdeURLRef.child("cdeApiIP").observe(.value, with: { (snapshot) in
            ApiWorker.shared.cdeURL = snapshot.value as? String ?? ""
        })
    }
    
    func getWeekEven() {
        let cdeURLRef = Database.database().reference(withPath: "/config")
        cdeURLRef.child("week").observe(.value, with: { (snapshot) in
            Config.weekConf = snapshot.value as? Int ?? Config.weekConf
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

