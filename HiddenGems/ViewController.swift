//
//  ViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 2/23/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData


var user = ""
var user_id = 0


// Function to remove keyboard on touch
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var CreateAccount: UIButton!
    @IBOutlet weak var logInBox: UIView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!



    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "HiddenGemsBackground.png")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        self.logInBox.layer.cornerRadius = 10
        self.logInBox.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        self.hideKeyboardWhenTappedAround()
        
        
        //refers to AppDelegate
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //allows to access coredata database
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "USER")
        
        request.returnsObjectsAsFaults = false

        
        do{
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0{
                
                for result in results as! [NSManagedObject]{
                
                    user = result.valueForKey("username")! as! String
                    user_id = result.valueForKey("id") as! Int
                }
                self.performSegueWithIdentifier("LoginToExplore", sender: nil)
            }
            
        }catch{
            print("Error fetching")
        }
        
        print("The user is: " + user)
        
        
        
        
        
    }

    
    @IBAction func LogInButton(sender: UIButton) {
        
        
        
        
        if (self.username.text!.isEmpty) || (self.password.text!.isEmpty) {
            
            let alert = UIAlertView()
            alert.title = "Empty field"
            alert.message = "Please enter information in every field"
            alert.addButtonWithTitle("Ok")
            alert.show()
            
        }else{
            
            postLogIn()
            
        }
        
        
       
        
        
    }
    
    //Function that allows us to make a POST request to send User and Password for Login
    
    
    func postLogIn(){
        
        
        let url = NSURL(string:"http://54.152.30.2/hg/login")!
        let session = NSURLSession.sharedSession()
        let postParams = ["username":self.username.text!, "password":self.password.text!] as Dictionary<String, String>
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print(postParams)
            
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
                        alert.title = "Login error"
                        alert.message = "Invalid password/username"
                        alert.addButtonWithTitle("Try again")
                        alert.show()
                        
                    })
                    
                    return
            }
            
            if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                print("POST: " + postString)
                self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
                
                
                //force queue to come to a close.
                dispatch_async(dispatch_get_main_queue(),{() ->Void in
                    
                    
                        do{
                            
                            let jsondata =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                           
                            let username = jsondata["username"] as! String
                            
                            user = username
                            user_id = jsondata["user_id"] as! Int
                            
                            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            
                            let context: NSManagedObjectContext = appDel.managedObjectContext
                            
                            let request = NSFetchRequest(entityName: "USER")
                            
                            request.returnsObjectsAsFaults = false
                            
                            //Predicate to the request which is a instruction that says I want to search for things the look like this:
                            
                            //Format:String is a the rule that determine the request of predicate
                            //username = %@    %@ represents a string    "username" is the argument
                            
                            request.predicate = NSPredicate(format: "username = %@", username)
                            
                            do {
                                let results = try context.executeFetchRequest(request)
                                
                                //If username existes in database, update its values
                                if results.count > 0{
                                    for result in results as! [NSManagedObject]{
                                        
                                        result.setValue(jsondata["password"], forKey: "password")
                                        result.setValue(jsondata["email"], forKey: "email")
                                        result.setValue(jsondata["country_code"], forKey: "ctry_code")
                                        result.setValue(jsondata["phone_number"], forKey: "phone")
                                        result.setValue(jsondata["user_id"], forKey: "id")
                                        
                                        do{
                                            try context.save()
                                        }catch{
                                            print("There was a problem while saving into USER")
                                        }
                                        
                                    }
                                }else{
                                    
                                    //If it doesn't exist save in database
                                    let entity = NSEntityDescription.entityForName("USER", inManagedObjectContext: context)
                                    
                                    let newUser = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
                                    
                                    newUser.setValue(jsondata["username"], forKey: "username")
                                    newUser.setValue(jsondata["password"], forKey: "password")
                                    newUser.setValue(jsondata["email"], forKey: "email")
                                    newUser.setValue(jsondata["country_code"], forKey: "ctry_code")
                                    newUser.setValue(jsondata["phone_number"], forKey: "phone")
                                    newUser.setValue(jsondata["user_id"], forKey: "id")

                                    
                                    do{
                                        try context.save()
                                    }catch{
                                        print("There was a problem while saving into USER")
                                    }
            
                                }
                                
                            }catch{
                                print("Error fetching")
                            }
                            
                            
                        }catch{
                            print("Error")
                        }
                        
                    
                    self.performSegueWithIdentifier("LoginToExplore", sender: nil)

                    })


            }
        }).resume()
        
        
        
    }
    
    func  updatePostLabel(text: String) {
        print("POST : " + "Successful")
     
    }
    


    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindAction(sender: UIStoryboardSegue){
        
        self.username.text = ""
        self.password.text = ""
        
    }
    
    
    //Show NavigationBar
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    //Send user name through segue to ExploreViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LoginToExplore"{
            let exploreVC: ExploreViewController = segue.destinationViewController as! ExploreViewController
        
            exploreVC.receivedUser = user}
        
        
    }
    
    
    
    
    /*override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }*/


}

