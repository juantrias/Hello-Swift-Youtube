//
//  RealmHelper.swift
//  Hello Swift Youtube
//
//  Created by Juan on 04/09/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import Foundation

// Singleton in Swift:  http://stackoverflow.com/questions/24024549/dispatch-once-singleton-model-in-swift

let sharedRealmHelper = RealmHelper()

class RealmHelper {
    class var sharedHelper:RealmHelper {
        return sharedRealmHelper
    }
    
    // Create a separate thread (with a serial dispatch queue) for Realm writes
    // From Realm docs: "Please note that writes block each other, and will block the thread they are made on if other writes are in progress. This is similar to any other persistence solution, so we do recommend that you use the usual best-practices for that situation, namely offloading your writes to a separate thread"
    
    // Create other queues for other realms ??
    
    var defaultRealmWriteQueue = dispatch_queue_create("default-realm-write-queue", nil)
    var notificationToken: RLMNotificationToken
    
    init() {
        self.notificationToken = RLMRealm.defaultRealm().addNotificationBlock { (notification: String!, realm: RLMRealm!) in
            println("Realm updated, video count: \(VideoDto.allObjects().count)")
        }
    }
    
    deinit {
        RLMRealm.defaultRealm().removeNotification(self.notificationToken)
    }
    
    /**
    Perform write operations in the default Realm writing dedicated thread
    */
    func writeAsync(block: (realm: RLMRealm) -> Void) {
        dispatch_async(defaultRealmWriteQueue, {
            let realm = RLMRealm.defaultRealm()
            block(realm: realm)
        })
    }
    
    // TODO: Write async in realm with name
    //func writeAsyncInRealm(realmName: String, block: (realm: RLMRealm) -> Void) {
}