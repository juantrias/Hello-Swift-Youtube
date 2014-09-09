//
//  AppDelegate.swift
//  Hello Swift Youtube
//
//  Created by Juan on 21/08/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var numberOfCallsToSetVisible = 0

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        println("NSUserDefaults path: \(paths[0])/Preferences")
        //println("NSUserDefaults allKeys:\(NSUserDefaults.standardUserDefaults().dictionaryRepresentation())")
        
        // MARK: DEBUG Reset preferences on every launch
        /*let def = NSUserDefaults.standardUserDefaults()
        def.removeObjectForKey(SP_KEY_LAST_SEARCH_STRING)
        def.removeObjectForKey(SP_KEY_LAST_CACHED_SEARCH_STRING)
        def.removeObjectForKey(SP_KEY_LAST_SEARCH_RESULT_COUNT)
        def.synchronize()
        println(">>>>>>>DEBUG<<<<<<< NSUserDefaults deleted")
        
        def.setObject("Google IO 2014", forKey:SP_KEY_LAST_SEARCH_STRING)
        def.synchronize()*/
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Custom methods
    
    func setNetworkActivityIndicatorVisible(visible: Bool) {
        if (visible) {
            numberOfCallsToSetVisible++
        } else if (numberOfCallsToSetVisible > 0) {
            numberOfCallsToSetVisible--
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = numberOfCallsToSetVisible > 0
    }

}

