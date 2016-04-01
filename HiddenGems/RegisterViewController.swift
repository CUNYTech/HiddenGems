//
//  RegisterViewController.swift
//  HiddenGems
//
//  Created by Bryan Posso on 3/9/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var registerBox: UIView!
    @IBOutlet weak var fullName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Blue box view that contains textfields.
        registerBox.layer.cornerRadius = 10;
      

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.username.text = ""
                self.password.text = ""
                self.email.text = ""
                self.repeatPassword.text = ""
                self.fullName.text = ""
                
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

    



}
