//
//  AccessToApiKeys.swift
//  GoogleMaps_Task
//
//  Created by Esraa Mohamed Ragab on 6/18/20.
//  Copyright © 2020 Esraa. All rights reserved.
//

import Foundation

func valueForAPIKey(named keyname:String) -> String {
    // Credit to the original source for this technique at
    // http://blog.lazerwalker.com/blog/2014/05/14/handling-private-api-keys-in-open-source-ios-apps
    let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    let value = plist?.object(forKey: keyname) as! String
    return value
}
