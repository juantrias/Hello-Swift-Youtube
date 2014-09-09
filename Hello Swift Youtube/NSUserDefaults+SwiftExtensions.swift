//
//  NSUserDefaults+SwiftExtensions.swift
//  Hello Swift Youtube
//
//  Created by Juan on 09/09/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    /**
    We need to instantiate a NSDictionary to store a Dictionary in NSUserDefaults. Waiting for a more elegant solution
    */
    func setDictionary(dictionary: [String:AnyObject], forKey key: String) {
        setObject(NSDictionary(dictionary:dictionary), forKey: key)
    }
}