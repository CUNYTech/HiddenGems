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
        
        
        if (self.username.text!.isEmpty) || (self.password.text!.isEmpty) || (self.repeatPassword.text!.isEmpty) || (self.email.text!.isEmpty) {
            
            let alert = UIAlertView()
            alert.title = "Empty text field"
            alert.message = "Please enter information in every text field"
            alert.addButtonWithTitle("Ok")
            alert.show()
            
        }else if repeatPassword.text == password.text {
            
                postCreateUser()
                coreDataCreateUser()
                self.username.text = ""
                self.password.text = ""
                self.email.text = ""
                self.repeatPassword.text = ""
            
            }else{
                self.repeatPassword.layer.borderWidth = 3
                self.repeatPassword.layer.borderColor = UIColor.redColor().CGColor
                self.repeatPassword.text = ""
    
            
        }
       
      
    }
    

    
    
    //Function that allows us to make a POST request to Create an account
    
    func postCreateUser(){
        
        let url = NSURL(string:"http://54.152.30.2/hg/createuser")!
        let session = NSURLSession.sharedSession()
        let postParams = ["username":self.username.text!, "password":self.password.text!, "email":self.email.text!] as Dictionary<String, String>
        
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
                    print(data)
                    print(response)
                    print(error)
                    return
                    
            }
            
            if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                
                
                print("POST:" + postString)
                self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
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
            print(results)
            
        }catch{
            
            print("There was a problem fetching ")
        }
        
    }

    



}
