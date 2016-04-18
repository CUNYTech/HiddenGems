//
//  RegisterViewController.swift
//  HiddenGems
//
//  Created by Bryan Posso on 3/9/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var registerBox: UIView!
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Blue box view that contains textfields.
        registerBox.layer.cornerRadius = 10;
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
      

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Show NavigationBar
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    
   //Button that calls the postCreate function and validates user entry to create new account. 
    
    
    @IBAction func registerButton(sender: UIButton) {
        
        
        if (self.username.text!.isEmpty) || (self.password.text!.isEmpty) || (self.repeatPassword.text!.isEmpty) || (self.email.text!.isEmpty){
            
            let alert = UIAlertView()
            alert.title = "Empty field"
            alert.message = "Please enter information in every field"
            alert.addButtonWithTitle("Ok")
            alert.show()
            
        }else if repeatPassword.text == password.text {
            
            postCreateUser()
            
            }else{
                self.repeatPassword.layer.borderWidth = 3
                self.repeatPassword.layer.borderColor = UIColor.redColor().CGColor
                self.repeatPassword.text = ""
    
            
        }
       
      
    }
    
    //Function that allows us to make a POST request to Create an account
    
    func postCreateUser(){
        
        let url = NSURL(string:"http://54.152.30.2/hg/cuser")!
        let session = NSURLSession.sharedSession()
        let postParams = ["username":self.username.text!, "password":self.password.text!, "email":self.email.text!, "country_code":self.countryCode.text!, "phone_number":self.phone.text!] as Dictionary<String, String>
        
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
                        alert.title = "Create account error"
                        alert.message = "Couldn't create account"
                        alert.addButtonWithTitle("Ok")
                        alert.show()

                    })
                    return
                    
            }
            
            if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                
                
                print("POST:" + postString)
                self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    //Save user in local database
                    self.coreDataCreateUser()

                    //Alert to show the status of the request
                    let alert = UIAlertController(title: "Account Created", message: "Your account has been created successfully", preferredStyle: .Alert)
                    
                    let actionA = UIAlertAction(title: "Ok", style: .Default, handler: { (action:UIAlertAction) -> Void in
                        self.username.text = ""
                        self.password.text = ""
                        self.email.text = ""
                        self.repeatPassword.text = ""
                        self.countryCode.text = ""
                        self.phone.text = ""
                        
                    })
                    
                    alert.addAction(actionA)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    
                    })
                
                
            }
        }).resume()
        
    }
    
    
    
    func updatePostLabel(text: String) {
        print("POST : " + "Successful")
    }
    
    
    func coreDataCreateUser(){
        
        //Variable that allows us to work with the default AppDelegate
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Context variable, context is the handler for us to access the database
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("USER", inManagedObjectContext: context)
    
        let newUser = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
        
        newUser.setValue(username.text, forKey: "username")
        
        newUser.setValue(password.text, forKey: "password")
        
        newUser.setValue(email.text, forKey: "email")
        
        newUser.setValue(phone.text, forKey: "phone")
        
        newUser.setValue(countryCode.text, forKey: "ctry_code")
        
        do{
            try context.save()
            
        }catch{
            
            print("There was a problem while saving into USER")
        }
        
        //To fecth information from the ENTITY -> USER
        let request = NSFetchRequest(entityName: "USER")
        
        //To be able to access the data and see its values
        request.returnsObjectsAsFaults = false
        
        do{
            
            let results = try context.executeFetchRequest(request)
            //print(results)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    print(result.valueForKey("username")!)
                    print(result.valueForKey("password")!)
                    print(result.valueForKey("email")!)
                    if (result.valueForKey("phone") != nil) {
                        print(result.valueForKey("phone")!)
                    }else{
                        print("No phone")
                    }
                    if (result.valueForKey("ctry_code") != nil){
                        print(result.valueForKey("ctry_code")!)
                    }else{
                        print("No country_code")
                    }
                }
            }
            
        }catch{
            
            print("There was a problem fetching results ")
        }
        
        
        
    }

    



}
