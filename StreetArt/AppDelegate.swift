//
//  AppDelegate.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/6/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var mainController: MainViewController?
    var favoritesController: FavoritesViewController?
    var settingsController: SettingsViewController?

    var tabBarController: UITabBarController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

#if PRODUCTION_BUILD
        FirebaseApp.configure()
#endif

        let titleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: Color.text
        ]

        UINavigationBar.appearance().tintColor = Color.highlight
        UINavigationBar.appearance().titleTextAttributes = titleAttributes

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.tintColor = Color.highlight

        mainController = MainViewController()
        let mainNavController = UINavigationController(rootViewController: mainController!)

        favoritesController = FavoritesViewController()
        let favoritesNavController = UINavigationController(rootViewController: favoritesController!)

        settingsController = SettingsViewController()
        let settingsNavController = UINavigationController(rootViewController: settingsController!)

        tabBarController = UITabBarController()
        tabBarController?.viewControllers = [ mainNavController, favoritesNavController, settingsNavController ]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        NotificationCenter.default.addObserver(self, selector: #selector(logoutAction(_:)), name: .userDidLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logoutAction(_:)), name: .userDidLogout, object: nil)

        return true
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
        LocalAnalytics.shared.appOpen()
        self.mainController?.reloadSubmissions(reset: true, showHud: true)
        DataManager.shared.fetchUser(completionHandler: nil)
        DataManager.shared.fetchReportCodes(force: true, completionHandler: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NotificationCenter.default.removeObserver(self, name: .userDidLogin, object: nil)
        NotificationCenter.default.removeObserver(self, name: .userDidLogout, object: nil)
    }

}

// MARK: - Observers

extension AppDelegate {

    @objc func loginAction(_ notification: Notification) {
        LocalAnalytics.shared.customEvent(.login)
        mainController?.reloadSubmissions(reset: true, showHud: true)
        DataManager.shared.fetchUser(completionHandler: nil)
        DataManager.shared.fetchReportCodes(force: true, completionHandler: nil)
    }

    @objc func logoutAction(_ notification: Notification) {
        LocalAnalytics.shared.customEvent(.logout)
        DataManager.shared.resetUser()
        mainController?.reloadSubmissions(reset: true, showHud: true)
    }

}

