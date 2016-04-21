//
//  MapViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 2/23/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook
import MapKit

//Goblal variables


var xloc: CLLocationDegrees!
var yloc: CLLocationDegrees!

var venueList: [NSDictionary]!
//var exploreVenueList : NSDictionary!
var exploreVenueList: NSMutableArray!

//var imageCache = [String: NSData]()
var exploreImageCache = [String: NSData]()

var centerPoint: CLLocationCoordinate2D!

var radius: Double!

var tempSize: Int!


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let fqClient_id = "XC5G1YSZQWRNB0UH1VMDAMKZWX453N1IPUHWNO1XHG5AC3VH"
    let fqClient_secret = "5XGRVKYPGJHPK5NGODYBTI2GKQU2JUMJQMAXYMTS2TTZ3RXX"
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var radiusText: UITextField!
    
    @IBOutlet weak var radiusSlider: UISlider!
    
    @IBOutlet weak var findEvents: UIButton!
    
    let locationManager = CLLocationManager()
    
    var circleOverlay = MKCircle()
    
    var circleRenderer = MKCircleRenderer()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        self.mapView.showsUserLocation = true
        
        self.mapView.mapType = .Standard
        
        self.radiusText.enabled = false
        
        self.findEvents.layer.cornerRadius = 10
        
        if(exploreVenueList != nil){
            if tempSize != preferenceList?.count{
                tempSize = preferenceList.count
                explore()
            }else{
                
                pinExploreVenuesList()
            }
            
            
            
        }
        
        if radius != nil && centerPoint != nil {
            radiusText.text! = String(radius)
            radiusSlider.value = Float(radius)
            
            // mapView.addOverlay(MKCircle(centerCoordinate: centerPoint, radius: CLLocationDistance(Double(radius))))
            
        }
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
        
        print("LIST IN MAP ======" + String(preferenceList))
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let myLocation = locations.last
        
        centerPoint = CLLocationCoordinate2D(latitude: myLocation!.coordinate.latitude, longitude: myLocation!.coordinate.longitude)
        
        // let regionDistance:CLLocationDistance = 3300
        
        //let region = MKCoordinateRegionMakeWithDistance(centerPoint, regionDistance, regionDistance)
        
        let region = MKCoordinateRegion(center: centerPoint, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        // self.locationManager.stopUpdatingLocation()
        
        //print(myLocation?.coordinate.latitude)
        
        if(xloc != myLocation?.coordinate.latitude || xloc == nil){
            xloc = myLocation!.coordinate.latitude
            yloc = myLocation!.coordinate.longitude
            
            print("calling explore()")
            explore()
        }
        
    }
    
    func explore(){
        //Using foursquare api: "explore"
        
        //Setup for formatting data to use in foursquare api
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyymmdd"
        
        //format todays date to yymmdd format
        let date : String = dateFormatter.stringFromDate(NSDate())
        
        let baseURL : NSString = "https://api.foursquare.com/v2/venues/explore?ll="+String(xloc)+","+String(yloc) as NSString
        //print("This is the baseURL " + (baseURL as String))
        
        let creds : NSString = "&client_id="+fqClient_id+"&client_secret="+fqClient_secret+"&v="+date as NSString
        //print("This are the credentials " + (creds as String))
        
        let radius : NSString = "&radius="+String(radiusText.text!)+"&limit=50" as NSString
        //print("This is the given radius " + (radius as String))
        
        exploreImageCache = [String:NSData]()
        
        var first = true
        
        var t = 0
        
        for pref in preferenceList{
            let pref = pref["place_name"] as! String
            let section : NSString = "&section=" + String(pref) as NSString
            let venues : NSString = (baseURL as String) + (creds as String) + (radius as String) + (section as String) as NSString
            
            let venuesURL = NSURL(string: venues as String)
            
            if let url = venuesURL {
                
                //print("this is URL: " + String(url) + "\n")
                
                //create session
                //let session instead of _
                _ = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    
                    guard let realResponse = response as? NSHTTPURLResponse where
                        realResponse.statusCode == 200 else {
                            print("Not a 200 response")
                            //print(data)
                            //print(response)
                            //print(error)
                            
                            
                            return
                    }
                    
                    if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                        print("POST: " + postString)
                        self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
                    
                    if let urlContent = data{
                        
                        //print("This is data: " + String(urlContent))
                        
                        //convert to json
                        let jsondata = NSData(data: urlContent)
                        
                        //print("This is jsondata " + String(jsondata))
                        
                        do{
                            let content = try NSJSONSerialization.JSONObjectWithData(jsondata, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            
                            //print("This is content: " + String(content))
                            
                            let response = content["response"] as! NSDictionary
                            
                            //print("This is response: " + String(response))
                            
                            let groups = response["groups"] as! NSArray
                            
                            //print("This is groups: " + String(groups.count))
                            
                            let items = groups[0] as! NSDictionary
                            
                            //print("This is items: " + String(items.count))
                            
                            let venues = items["items"] as! NSMutableArray
                            
                            //print("These are the venues: " + String(venues.count))
                            
                            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                                
                                if first{
                                    exploreVenueList = venues as NSMutableArray
                                    first = false
                                }else{
                                    for i in venues{
                                        exploreVenueList.addObject(i)
                                    }
                                    
                                }
                                
                                if t == preferenceList.count{
                                    self.pinExploreVenuesList()
                                    
                                }
                                
                                //print("Explore list " + String(exploreVenueList.count))
                                //exploreImageCache = [String: NSData]()
                                //self.pinExploreVenuesList()
                            })
                            
                            t = t + 1
                            
                            
                            
                        }catch{
                            print("Error")
                        }
                        
                        
                    }
                    
                    
                    
                    }
                }).resume()
                
                
                
            }
            
        }
        
        /* let venues : NSString = (baseURL as String) + (creds as String) + (radius as String) as NSString
        //print("This is the list or venues" + (venues as String))
        
        
        //venues url!
        let venuesURL = NSURL(string: venues as String)
        //print("This is the venues URL " + String(venuesURL))
        
        
        
        if let url = venuesURL {
        
        //print("this is URL: " + String(url) + "\n")
        
        //create session
        //let session instead of _
        _ = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
        
        guard let realResponse = response as? NSHTTPURLResponse where
        realResponse.statusCode == 200 else {
        print("Not a 200 response")
        //print(data)
        //print(response)
        //print(error)
        
        
        return
        }
        
        if let urlContent = data{
        
        //print("This is data: " + String(urlContent))
        
        //convert to json
        let jsondata = NSData(data: urlContent)
        
        //print("This is jsondata " + String(jsondata))
        
        do{
        let content = try NSJSONSerialization.JSONObjectWithData(jsondata, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        
        //print("This is content: " + String(content))
        
        let response = content["response"] as! NSDictionary
        
        //print("This is response: " + String(response))
        
        let groups = response["groups"] as! NSArray
        
        //print("This is groups: " + String(groups.count))
        
        let items = groups[0] as! NSDictionary
        
        //print("This is items: " + String(items.count))
        
        let venues = items["items"] as! NSArray
        
        //print("These are the venues: " + String(venues.count))
        
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
        exploreVenueList = venues
        print("Explore list " + String(exploreVenueList.count))
        exploreImageCache = [String: NSData]()
        self.pinExploreVenuesList()
        })
        
        
        
        }catch{
        print("Error")
        }
        
        
        }
        
        
        
        
        }).resume()
        
        
        }*/
        
    }
    
    func pinExploreVenuesList(){
        
        //remove all annotations
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        if exploreVenueList != nil {
            //print("Explore list count : " + String(exploreVenueList.count))
            
            for venue in exploreVenueList{
                let location = (venue["venue"] as! NSDictionary)["location"] as! NSDictionary
                
                let name = (venue["venue"] as! NSDictionary)["name"] as! String
                
                let category = ((venue["venue"]as! NSDictionary)["categories"] as! NSArray)[0] as! NSDictionary
                
                let prefix = (category["icon"] as! NSDictionary)["prefix"] as! NSString
                let suffix = (category["icon"] as! NSDictionary)["suffix"] as! NSString
                let url = NSURL(string: (prefix as String)+"bg_512"+(suffix as String))!
                let id = (venue["venue"] as! NSDictionary)["id"] as! NSString
                
                //let session
                _ = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data:NSData?, response:NSURLResponse?, Error) -> Void in
                    
                    
                    if(data != nil){
                        dispatch_async(dispatch_get_main_queue(), {() -> Void in
                            exploreImageCache[id as String] =  data! as NSData
                            
                            
                        })
                    }
                }).resume()
                
                //get latitude longitude
                let lat : CLLocationDegrees = location["lat"] as! CLLocationDegrees
                let lng : CLLocationDegrees = location["lng"] as! CLLocationDegrees
                
                //convert coordinate to CLLocationCoordinate2D type
                
                let newCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
                
                //create new annotation for each venue
                let annotation = MKPointAnnotation()
                //var annotation = CustomPointAnnotation(pinColor: UIColor.purpleColor())
                annotation.coordinate = newCoordinate
                
                annotation.title = name
                
                //add annotation to the map
                mapView.addAnnotation(annotation)
                
                
                
            }
            
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors:" + error.localizedDescription)
    }
    
    
    
    
    // MARK: - Radius
    
    @IBAction func setARadius(sender: UISlider) {
        
        let slider = sender.value
        
        radiusText.text = String(slider)
        
        radius = Double(slider)
        //print(radiusSlider.value)
        
        explore()
        
        mapView.removeOverlays(mapView.overlays)
        
        mapView.addOverlay(MKCircle(centerCoordinate: centerPoint, radius: CLLocationDistance(Double(slider))))
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.purpleColor()
            circleRenderer.alpha = 0.2
            
        }
        return circleRenderer
    }
    
    
    //Show NavigationBar.
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    func  updatePostLabel(text: String) {
        print("POST : " + "Successful")
        
    }
    
    
    
    /* @IBAction func DrawCircle(sender: UIButton) {
    
    
    let radiusCircle:CLLocationDistance = Double(radiusSlider.value)
    
    
    mapView.addOverlay(MKCircle(centerCoordinate: centerPoint, radius: radiusCircle))
    
    }
    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    */
    
}
