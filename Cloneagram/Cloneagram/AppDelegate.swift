//
//  AppDelegate.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 01..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainStoryBoard: UIStoryboard!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if FirebaseManager.shared.isLoggedIn {
            showMainScreen()
        } else {
            showLoginScreen()
        }
        
        return true
    }
    
    func showMainScreen() {
        let rootController = mainStoryBoard.instantiateViewController(withIdentifier: "MainScreenViewController")
        changeRootAnimated(UINavigationController(rootViewController: rootController))
    }
    
    func showLoginScreen() {
        changeRootAnimated(mainStoryBoard.instantiateInitialViewController()!)
    }
    
    func changeRootAnimated(_ rootViewController: UIViewController) {
        let snapShot = (window?.snapshotView(afterScreenUpdates: true))!
        rootViewController.view.addSubview(snapShot)
        window?.rootViewController = rootViewController
        
        UIView.animate(withDuration: 0.5, animations: {
            snapShot.layer.opacity = 0.0
            snapShot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: { (finished) in
            snapShot.removeFromSuperview()
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

