//
//  PreferencesViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 3/31/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

class PreferencesViewController: UIViewController {
    
    
    @IBOutlet var toggleTags: [UISwitch]!

    
    @IBOutlet weak var categoriesBox: UIView!
    
    
    @IBAction func preferenceToggle(sender:UISwitch){
        
        let found = sender.on
        
        
        print("STATE: " + String(found))
        
        let attemptUrl = NSURL(string: "http://54.152.30.2/hg/setPreferences")
        
        if !found{
            
            print("Clicked to delete")

        
        for preference in preferenceList{
            let prefId = preference["pref_id"] as! Int
            
            if sender.tag == prefId{
                //removing preference
                
                if let url = attemptUrl{
                    
                    //create session
                    let session = NSURLSession.sharedSession()
                    
                    let postParams = ["user_id": String(user_id), "pref_id": String(sender.tag), "action":"delete"] 
                    
                    let request = NSMutableURLRequest(URL: url)
                    //set to post method
                    request.HTTPMethod = "POST"
                    request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
                    
                    do{
                        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
                        //print(postParams)
                    }catch{
                        print("JSON serialization failed")
                    }
                    
                    session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                        guard let realResponse = response as? NSHTTPURLResponse where
                            realResponse.statusCode == 200 else {
                                print("Not a 200 response")
                                //print(data)
                                //print(response)
                                //print(error)
                                
                                //force queue to come to a close so we can display the alert
                                dispatch_async(dispatch_get_main_queue(),{() ->Void in
                                    print("Alert")
                                    
                                })
                                
                                return
                        }
                        
                        if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                            print("POST: " + postString)
                            self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
                            
                                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                                    
                                    do{
                                        
                                        let jsondata =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                                        
                                        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                        
                                        let context: NSManagedObjectContext = appDel.managedObjectContext
                                        
                                        let request = NSFetchRequest(entityName: "PREFERENCES")
                                        
                                        request.returnsObjectsAsFaults = false
                                        
                                        preferenceList = jsondata
                                        
                                        print("The new preference list is::::: " + String(preferenceList))

                                        
                                        request.predicate = NSPredicate(format: "preference_id == \(sender.tag)")
                                        
                                        do{
                                            let results = try context.executeFetchRequest(request)
                                            
                                            if results.count > 0{
                                                for result in results as! [NSManagedObject]{
                                                    //print(result.valueForKey("preference_name"))
                                                    
                                                    
                                                    context.deleteObject(result)
                                                    do{
                                                        try context.save()
                                                    }catch{
                                                        print("there was a problem saving")
                                                    }
                                                }
                                            }// for results > 0
                                            
                                            
                                        }catch{
                                            print("Error fetching")
                                        }
                                        
                                        
                                    }catch{
                                        print("Error fetching")
                                    }
                            })//Dispatch
                        }//DO JSON
                }).resume()
            }
                print("Bingo!")
                
                //break
            }
            
            
            }
            
            //-------
            
            }else{ //else found
            print("clicked to add")
            
            if let url = attemptUrl {
                
                let postParams = ["user_id": String(user_id), "pref_id": String(sender.tag), "action":"add"]
                
                //create session
                let session = NSURLSession.sharedSession()
                
                
                //prepare data for post request
                //create a request instance
                let request = NSMutableURLRequest(URL: url)
                //set to post method
                request.HTTPMethod = "POST"
                request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
                
                do{
                    request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
                    //print(postParams)
                }catch{
                    print("JSON serialization failed")
                }
                
                session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    guard let realResponse = response as? NSHTTPURLResponse where
                        realResponse.statusCode == 200 else {
                            print("Not a 200 response")
                            //print(data)
                            //print(response)
                            //print(error)
                            
                            //force queue to come to a close so we can display the alert
                            dispatch_async(dispatch_get_main_queue(),{() ->Void in
                                let alert = UIAlertView()
                                alert.title = "Preferences error"
                                alert.message = "Error while saving preferences"
                                alert.addButtonWithTitle("Try again")
                                alert.show()
                                
                            })
                            
                            return
                    }
                    
                    if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                        //print("POST: " + postString)
                        self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
                        
                        //force queue to come to a close
                        dispatch_async(dispatch_get_main_queue(), {() -> Void in
                            
                            
                            do{
                                
                                let jsondata =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                                
                                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                
                                let context: NSManagedObjectContext = appDel.managedObjectContext
                                
                                let request = NSFetchRequest(entityName: "PREFERENCES")
                                
                                request.returnsObjectsAsFaults = false
                                
                                preferenceList = jsondata
                                
                                print("LIST PREFERENCES ===== " + String(preferenceList))
                                
                                do{
                                    let results = try context.executeFetchRequest(request)
                                    
                                    if results.count == 0{
                                        
                                        //print("\n")
                                        //print("There's no preference set in db!")
                                        //print(jsondata)
                                        
                                        
                                        for pref in jsondata{
                                            
                                            let preference = NSEntityDescription.insertNewObjectForEntityForName("PREFERENCES", inManagedObjectContext: context)
                                            
                                            preference.setValue(pref["place_name"], forKey: "preference_name")
                                            preference.setValue(pref["pref_id"], forKey: "preference_id")
                                            preference.setValue(pref["user_id"], forKey: "id")
                                            
                                            do{
                                                try context.save()
                                            }catch{
                                                print("Error saving")
                                            }
                                            
                                        }
                                        
                                    }else{
                                        //print("\n")
                                        //print("There's no preference set in db!")
                                        //print(jsondata)
                                        
                                        
                                        for pref in jsondata{
                                            if (pref["pref_id"] as! Int == sender.tag){
                                                
                                                let preference = NSEntityDescription.insertNewObjectForEntityForName("PREFERENCES", inManagedObjectContext: context)
                                                
                                                preference.setValue(pref["place_name"], forKey: "preference_name")
                                                preference.setValue(pref["pref_id"], forKey: "preference_id")
                                                preference.setValue(pref["user_id"], forKey: "id")
                                                
                                                do{
                                                    try context.save()
                                                }catch{
                                                    print("Error saving")
                                                }
                                                
                                            }
                                            break
                                        }
                                        
                                    }
                                    
                                }catch{
                                    print("There was a problem while saving into PREFERENCES")
                                    
                                }
                                
                                
                            }catch{
                                print("Error fetching")
                            }
                            
                            
                            
                            
                        })
                        
                    }
                    
                    
                }).resume()
                
                
            }

            
        }
    
        //print("THE PREF LIST IS: " + String(preferenceList))
}

    

  /*  @IBAction func savePreferences(sender: AnyObject) {
        
        let alert = UIAlertView()
        alert.title = "Travel Preferences"
        alert.message = "Your travel preferences have been saved successfully"
        alert.addButtonWithTitle("Ok")
        alert.show()
    }*/
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoriesBox.layer.cornerRadius = 10
        
       // print("The toggle tags are:" + String(toggleTags))
        
        print("The list of preferences is: " + String(preferenceList))
        
        for tag in toggleTags{
            if (preferenceList.count > 0){
                for pref in preferenceList{
                    //This is from preferenceList Array
                    let prefId = pref["pref_id"] as! Int
                    if tag.tag == prefId {
                        tag.on = true
                        break
                    }
                    tag.on = false
                }
            }else{
                tag.on = false
            }
        }
        
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Show NavigationBar.
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
        
        
        func  updatePostLabel(text: String) {
            print("POST : " + "Successful")
            
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}//UIViewController Class
