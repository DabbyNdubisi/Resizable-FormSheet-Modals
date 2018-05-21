//
//  AppDelegate.swift
//  ResizableFormSheet
//
//  Created by Dabby Ndubisi on 2018-05-13.
//  Copyright © 2018 Dabby Ndubisi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	var router: Router?
	let baseViewController: UIViewController = {
		let vc = UIViewController()
		vc.view.backgroundColor = UIColor.white
		return vc
	}()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		window = UIWindow(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height))
		window?.rootViewController = baseViewController
		window?.makeKeyAndVisible()
		
		router = Router(baseViewController: baseViewController)
		router?.begin()
		
		return true
	}
}

