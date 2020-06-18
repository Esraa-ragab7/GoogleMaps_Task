//
//  ViewController.swift
//  GoogleMaps_Task
//
//  Created by Esraa Mohamed Ragab on 6/18/20.
//  Copyright © 2020 Esraa. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MainMapViewController: UIViewController {
    
    // MARK: - outlets
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Properties
    private var mainMapViewModal: MainMapViewModal = MainMapViewModal()
    
    // MARK: - Viewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainMapViewModal.initMap(mapView: mapView)
        navigationItem.titleView = mainMapViewModal.setSearchBar()
        definesPresentationContext = true
    }
}

