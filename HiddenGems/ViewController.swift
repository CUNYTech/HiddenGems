//
//  ViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 2/23/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit

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
        backgroundImage.image = UIImage(named: "background1.png")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        self.logInBox.layer.cornerRadius = 10
        self.logInBox.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        self.hideKeyboardWhenTappedAround()
        
        
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
        
        
        let url = NSURL(string:"http://54.152.30.2/hg/login_user")!
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
                    print(data)
                    print(response)
                    print(error)
                    
                    return
            }
            
            if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                print("POST: " + postString)
                self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
                
                
                //force queue to come to a close.
                dispatch_async(dispatch_get_main_queue(),{() ->Void in
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
    
    
    
    
    
    /*override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }*/


}

