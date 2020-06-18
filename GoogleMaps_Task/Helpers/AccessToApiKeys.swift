//
//  AccessToApiKeys.swift
//  GoogleMaps_Task
//
//  Created by Esraa Mohamed Ragab on 6/18/20.
//  Copyright © 2020 Esraa. All rights reserved.
//

import Foundation

func valueForAPIKey(named keyname:String) -> String {
    let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    let value = plist?.object(forKey: keyname) as! String
    return value
}
