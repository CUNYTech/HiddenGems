//
//  ExploreViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 3/1/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

//List of preferences
var preferenceList : NSArray!

class ExploreViewController: UIViewController {
    
    
    
    @IBOutlet weak var logout: UIButton!
    
    @IBOutlet weak var myAccount: UIButton!
    
    @IBOutlet weak var displayUsername: UILabel!
    
    //User passed from ViewController
    var receivedUser = ""
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "HiddenGemsBackground.png")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        
        //Display user in label
        
        displayUsername.text = "welcome, " + user
        
        //print("THE USER IS: " + user)
        
        let attemptUrl = NSURL(string: "http://54.152.30.2/hg/getPreferences")
        
        if let url = attemptUrl {
            
            //create session
            let session = NSURLSession.sharedSession()

            //prepare data for post request
            let postParams = ["user_id": String(user_id)] 
            
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
                            alert.message = "There was an error while loading Preferences"
                            alert.addButtonWithTitle("Try again")
                            alert.show()
                            
                        })
                        
                        return
                }//end if guard
                
                if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                    print("POST: " + postString)
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
                            
                            do{
                                let results = try context.executeFetchRequest(request)
                                
                                if results.count == 0{
                                    
                                    print("\n")
                                    print("There's no preference set in db!")
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
                                        
                                    }//End for pref in jsondata
                                    
                                   // preferenceList = jsondata
                                    print("The preferences are: " + String(preferenceList))
                                    print("\n\n")
                                    
                                }else{
                                
                                    print("There is preference saved in db!")
                                    var temp = [AnyObject]() //Array of any object
                                    
                                    for result in results as! [NSManagedObject]{
                                        var val = [String: AnyObject]()
                                        val["user_id"] = result.valueForKey("id")
                                        val["pref_id"] = result.valueForKey("preference_id")
                                        val["place_name"] = result.valueForKey("preference_name")
                                        print(val)
                                        temp.append(val)
                                        print("\n\n")
                                        
                                        // print("HOLA")
                                        
                                    }
                                    
                                    print(temp)
                                    preferenceList = temp
                                    print("\n\n")
                                    print(preferenceList)

                                }
                               // tempSize = preferenceList.count
                                
                                
                            }//End do JSON DATA
                            catch{
                                print("There was a problem while saving into PREFERENCES")

                            }
                            
                            
                        }catch{
                            print("Error fetching")
                        }

                        
                        
                        
                    })
                   
                }
                
            
            }).resume()
            
            
        }
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
    }
        
    
    
    @IBAction func logoutButton(sender: UIButton) {
        
        
        //refers to AppDelegate
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //allows to access coredata database
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        //create a request that allows us to get data from users entity
        let request = NSFetchRequest(entityName: "USER")
        
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    print("Deleting \(result)")
                    //Deleting everyone in the database
                    context.deleteObject(result)
                    
                    do{
                        try context.save()
                    }catch{
                        print("Error saving")
                    }
                }
            }else{
                print("no result to delete!")
            }
            
        }catch{
            print("Error fetching")
        }
        
        user = ""
        
        //Delete Preferences
        
        let requestPref = NSFetchRequest(entityName: "PREFERENCES")
        
        requestPref.returnsObjectsAsFaults = false
        
        do{
            let resultsPref = try context.executeFetchRequest(requestPref)
            
            if resultsPref.count > 0{
                for result in resultsPref as! [NSManagedObject]{
                    
                    print("Deleting \(result)")
                    //Deleting every preference in the database
                    context.deleteObject(result)
                    
                    do{
                        try context.save()
                    }catch{
                        print("Error saving")
                    }
                }
            }else{
                print("no result to delete!")
            }
            
        }catch{
            print("Error fetching")
        }


        
        
    }//End of logoutButton

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //Hide NavigationBar.
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    //Send user name through segue to MyAccountViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "to_MyAccount"{
            let myAccount:MyAccountViewController = segue.destinationViewController as! MyAccountViewController
            myAccount.receivedUser = receivedUser
        }
        
    }
    
    func  updatePostLabel(text: String) {
        print("POST : " + "Successful")
        
    }
    

}
