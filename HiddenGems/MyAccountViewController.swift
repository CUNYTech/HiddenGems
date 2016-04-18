//
//  MyAccountViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 3/31/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

class MyAccountViewController: UIViewController {

    @IBOutlet weak var updateBox: UIView!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var ctry_code: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var updateButton: UIButton!
    
    //User passed from ExploreViewController
    var receivedUser = ""
    var user = ""
    
    
    
    
    @IBAction func updateAccount(sender: UIButton) {
        
        postUpdateUser()
        
    }
    
    
    @IBAction func editTextFields(sender: UIBarButtonItem) {
        //username.enabled = true
        //username.textColor = UIColor.blackColor()
        
        //password.enabled = true
        //password.textColor = UIColor.blackColor()
        //password.secureTextEntry = false

        //repeatPassword.enabled = true
        //repeatPassword.textColor = UIColor.blackColor()
       // repeatPassword.text = ""
        
        email.enabled = true
        email.textColor = UIColor.blackColor()

        phone.enabled = true
        phone.textColor = UIColor.blackColor()

        ctry_code.enabled = true
        ctry_code.textColor = UIColor.blackColor()

        updateButton.enabled = true
        updateButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBox.layer.cornerRadius = 0
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
        
        //to pass user as argument for coreDataLoadUserData(user)
        user = receivedUser
        
        //Load data into textfields
        coreDataLoadUserData(user)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Show NavigationBar.
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    
    //Function that loads data corresponding to user to text fields
    func coreDataLoadUserData(user:String){
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "USER")
        
        request.returnsObjectsAsFaults = false
        
        //Predicate to the request which is a instruction that says I want to search for things the look like this:
        
        //Format:String is a the rule that determine the request of predicate
        //username = %@    %@ represents a string    "mel" is the argument
        
        request.predicate = NSPredicate(format: "username = %@", user)
        
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    
                   //Casting to a string becasue it was a NSManagedObject
                    self.username.text = (result.valueForKey("username")! as! String)
                    self.password.text = (result.valueForKey("password")! as! String)
                     self.repeatPassword.text = (result.valueForKey("password")! as! String)
                    self.email.text = (result.valueForKey("email")! as! String)
                    //Check if user has phone number stored
                    if (result.valueForKey("phone") != nil){
                        self.phone.text = (result.valueForKey("phone")! as! String)}else{
                        self.phone.text = "No_phone"
                    }
                    //Check if user has country code stored
                    if (result.valueForKey("ctry_code") != nil){
                        self.ctry_code.text = (result.valueForKey("ctry_code")! as! String)}else{
                        self.ctry_code.text = "No_code"
                    }
                }
            }
            
        }catch{
            print("Error fetching")
        }
    
    }
    
    //Function that allows us to make a POST request to update account
    
    func postUpdateUser(){
        
        let url = NSURL(string:"http://54.152.30.2/hg/update_user")!
        let session = NSURLSession.sharedSession()
        let postParams = ["email":self.email.text!, "country_code":self.ctry_code.text!, "phone_number":self.phone.text!] as Dictionary<String, String>
        
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
                        alert.title = "Update account error"
                        alert.message = "Couldn't update account"
                        alert.addButtonWithTitle("Ok")
                        alert.show()
                        
                    })
                    return
                    
            }
            
            if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                
                
                print("POST:" + postString)
                self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    //Update user in local database
                    self.coreDataUpdateUserData(self.user)
                    
                    //Alert to show the status of the request
                    
                    let alert = UIAlertController(title: "Update Account", message: "Your account has been updated successfully", preferredStyle: .Alert)

                    let actionA = UIAlertAction(title: "Ok", style: .Default) { (action:UIAlertAction) -> Void in
                        self.username.enabled = false
                        self.username.textColor = UIColor.lightGrayColor()
                        
                        self.password.enabled = false
                        self.password.textColor = UIColor.lightGrayColor()
                        self.password.secureTextEntry = true
                        
                        self.repeatPassword.enabled = false
                        self.repeatPassword.textColor = UIColor.lightGrayColor()
                        //self.repeatPassword.text = ""
                        
                        self.email.enabled = false
                        self.email.textColor = UIColor.lightGrayColor()
                        
                        self.phone.enabled = false
                        self.phone.textColor = UIColor.lightGrayColor()
                        
                        self.ctry_code.enabled = false
                        self.ctry_code.textColor = UIColor.lightGrayColor()
                        
                        self.updateButton.enabled = false
                        self.updateButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
                    }
                    
                    alert.addAction(actionA)
                    self.presentViewController(alert, animated: true, completion: nil)

                    
                })
                
                
            }
        }).resume()
        
    }
    
    //Function that updates data
    func coreDataUpdateUserData(user:String){
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "USER")
        
        request.returnsObjectsAsFaults = false
        
        //Predicate to the request which is a instruction that says I want to search for things the look like this:
        
        //Format:String is a the rule that determine the request of predicate
        //username = %@    %@ represents a string    "mel" is the argument
        
        request.predicate = NSPredicate(format: "username = %@", user)
        
        do{
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    //result.setValue(self.username.text, forKey: "username")
                    //result.setValue(self.password.text, forKey: "password")
                    result.setValue(self.email.text, forKey: "email")
                    result.setValue(self.phone.text, forKey: "phone")
                    result.setValue(self.ctry_code.text, forKey: "ctry_code")
                    
                    do{
                        try context.save()
                    }catch{
                        print("Error saving")
                    }

                }
            }
            
        }catch{
            print("Error fetching")
        }
        
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

}
