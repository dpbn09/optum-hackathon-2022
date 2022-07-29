//
//  AppDelegate.swift
//  DigitalTwin
//
//  Created by its on 27/07/22.
//

import UIKit

enum Storyboards: String {
    case main = "Main"
}
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = setupTabBar()
        window?.tintColor = UIColor { $0.userInterfaceStyle == .light ? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
        window?.makeKeyAndVisible()
        return true
    }
    
    func setupTabBar() -> UITabBarController {
        let trackerVC = ViewController(storeManager: CareStoreReferenceManager.shared.synchronizedStoreManager)
        trackerVC.title = "Tracker"
        trackerVC.tabBarItem = UITabBarItem(
            title: "Tracker",
            image: UIImage(systemName: "heart.fill"),
            tag: 0
        )
        let root = UITabBarController()
        let trackerTab = UINavigationController(rootViewController: trackerVC)
        root.setViewControllers([trackerTab], animated: false)
        return root
    }
}

