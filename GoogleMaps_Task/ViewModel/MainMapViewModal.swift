//
//  MainMapViewModal.swift
//  GoogleMaps_Task
//
//  Created by Esraa Mohamed Ragab on 6/18/20.
//  Copyright © 2020 Esraa. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation
import GooglePlaces

class MainMapViewModal: NSObject {

    // MARK: - Properties
    var mapView: GMSMapView!
    let geoCoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D!
    var destinationLocation: CLLocationCoordinate2D!
    var marker: GMSMarker = GMSMarker()
    var zoomLevel: Float = 15.0
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var destinationMarker: GMSMarker = GMSMarker()
    var polyline: GMSPolyline = GMSPolyline()
    
    func initMap(mapView: GMSMapView){
        self.mapView = mapView
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = kCLDistanceFilterNone
            self.mapView.delegate = self
            self.mapView.isMyLocationEnabled = true
            self.mapView.settings.scrollGestures = true
            self.mapView.settings.zoomGestures = true
            self.mapView.settings.myLocationButton = true
            marker.map = self.mapView
        }
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.country = getCountryCode()
        resultsViewController?.autocompleteFilter = filter
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        searchController?.searchBar.sizeToFit()
        
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    func setSearchBar() -> UISearchBar {
        return searchController!.searchBar
    }
    
    func startUpdateLocation()  {
        self.locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocation Manager Delegate
extension MainMapViewModal: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            currentLocation = center
            setMapCamera(center: center)
            locationManager.stopUpdatingLocation()
        }
    }
    
    private func setMapCamera(center: CLLocationCoordinate2D) {
        CATransaction.begin()
        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        mapView?.animate(to: GMSCameraPosition.camera(withTarget: center, zoom: zoomLevel))
        CATransaction.commit()
    }
}

// MARK: - GMS Map View Delegate
extension MainMapViewModal: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        moveMarkerToLocation(location: coordinate)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        if mapView.myLocation?.coordinate != nil {
            moveMarkerToLocation(location: (mapView.myLocation?.coordinate)!)
        }

        return true
    }
    
    func moveMarkerToLocation(location: CLLocationCoordinate2D) {
        marker.map = nil
        marker = GMSMarker(position: location)
        marker.icon = GMSMarker.markerImage(with: UIColor.init(red: 34/255, green: 143/255, blue: 204/255, alpha: 1))
        marker.map = mapView
        
        getAddressFor(location: location) { (obtainedAddress, governorate) in
            self.marker.title = "Address : \(obtainedAddress)"
        }
        self.currentLocation = location
        if destinationLocation != nil {
            drawPathDirection()
        }
    }
    
    func getCountryCode() -> String {
        return "EG"
    }
    
    func getAddressFor(location: CLLocationCoordinate2D,
                       completionHandler: @escaping (_ address: String, _ governorate: String) -> ()) {
        
        getAddressName(location: location, completionHandler: completionHandler)
        
        
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: zoomLevel)
        
        mapView.animate(to: camera)
    }
}

// MARK: - GMS Autocomplete Results ViewController Delegate
extension MainMapViewModal : GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        destinationMarker.map = nil
        destinationMarker = GMSMarker(position: place.coordinate)
        destinationLocation = place.coordinate
        getAddressFor(location: place.coordinate) { (obtainedAddress, governorate) in
            self.destinationMarker.title = "Address : \(obtainedAddress)"
        }
        destinationMarker.map = mapView
        drawPathDirection()
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
      print("Error: ", error.localizedDescription)
    }
        
    func drawPathDirection() {
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        let destination = "\(destinationLocation.latitude),\(destinationLocation.longitude)"

        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&sensor=false&mode=driving&key=\(valueForAPIKey(named:"GOOGLE_MAPS_API_KEY"))"

        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                    DispatchQueue.main.async {
                        for route in routes
                        {
                            self.polyline.map = nil
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            self.polyline = GMSPolyline.init(path: path)
                            self.polyline.strokeWidth = 3

                            let bounds = GMSCoordinateBounds(path: path!)
                            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
                            self.polyline.strokeColor = UIColor.black
                            self.polyline.map = self.mapView
                        }
                    }
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
            }).resume()
    }

}
