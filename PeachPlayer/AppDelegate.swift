//
//  AppDelegate.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/8.
//  Copyright © 2016年 yxk. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        application.beginReceivingRemoteControlEvents()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        if Player.sharedInstance.player != nil && Player.sharedInstance.player.playing {
            application.beginReceivingRemoteControlEvents()
            self.becomeFirstResponder()
            Player.sharedInstance.configNowPlayingInfoCenter()

        }else{
            application.endReceivingRemoteControlEvents()
        }
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
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if url.absoluteString.rangeOfString("Documents/Inbox") !=  nil {
            if app.protectedDataAvailable {
                BEPAirDropHandler.sharedInstance().moveToLocalDirectoryAirDropURL(url)
            }else{
                BEPAirDropHandler.sharedInstance().saveAirDropURL(url)
            }
            //如果后台还在运行，则要通知更新  数据
            NSNotificationCenter.defaultCenter().postNotificationName("getFromAir", object: nil)
            return true
        }
        return false
        
    }

  
}

