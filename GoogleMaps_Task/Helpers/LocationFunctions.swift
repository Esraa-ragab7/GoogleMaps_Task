//
//  LocationFunctions.swift
//  Fatorty
//
//  Created by Abdelrahman Abu Sharkh on 8/20/19.
//  Copyright © 2019 Esraa Mohamed Ragab. All rights reserved.
//

import Foundation
import GoogleMaps

func getAddressName(location: CLLocationCoordinate2D,
                    completionHandler: @escaping (_ address: String, _ governorate: String) -> ()) {
    let geocoder = GMSGeocoder()
    
    
    var obtainedAddress = ""
    var governorate = ""
    //geocoder.accessibilityLanguage = "ar_sa"
    geocoder.reverseGeocodeCoordinate(location) { response , error in
        if let address = response?.firstResult() {
            let lines = address.lines! as [String]
            
            obtainedAddress = lines.joined(separator: "\n")
            governorate = address.lines?.last ?? ""
            completionHandler(obtainedAddress, governorate)
        }
    }
}
