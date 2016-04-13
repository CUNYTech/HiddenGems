//
//  GooglePlacesViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 4/6/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import GoogleMaps


class GooglePlacesViewController: UIViewController, CLLocationManagerDelegate {
    

    var googleMapView: GMSMapView!

    @IBOutlet var mapViewContainer: UIView!
    
    
    var locationManager: CLLocationManager!
    var placePicker: GMSPlacePicker!
    var latitude: Double!
    var longitude: Double!
    
    
    //Funtion to get near me locations
    @IBAction func exploreVenuesNearMe(sender: UIBarButtonItem) {
        
        
        // 1
        let center = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        self.placePicker = GMSPlacePicker(config: config)
        
        // 2
        placePicker.pickPlaceWithCallback { (place: GMSPlace?, error: NSError?) -> Void in
            
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                return
            }
            // 3
            if let place = place {
                let coordinates = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                let marker = GMSMarker(position: coordinates)
                marker.title = place.name
                marker.map = self.googleMapView
                marker.icon = UIImage(named: "marker_purple.png")
                self.googleMapView.animateToLocation(coordinates)
            } else {
                print("No place was selected")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()

        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        self.googleMapView = GMSMapView(frame: self.mapViewContainer.frame)
        self.googleMapView.animateToZoom(15.0)
        self.view.addSubview(googleMapView)

    }
    
    
    //Show NavigationBar
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func locationManager(manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]){
            // 1
            let location:CLLocation = locations.last!
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            
            // 2
            let coordinates = CLLocationCoordinate2DMake(self.latitude, self.longitude)
            let marker = GMSMarker(position: coordinates)
            marker.title = "I am here"
            marker.map = self.googleMapView
            marker.icon = UIImage(named: "marker_red.png")
            self.googleMapView.animateToLocation(coordinates)
    }
    
    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError){
            
            print("An error occurred while tracking location changes : \(error.description)")
    }
    
}
