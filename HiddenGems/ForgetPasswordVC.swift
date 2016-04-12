//
//  ForgetPasswordVC.swift
//  HiddenGems
//
//  Created by Bryan Posso on 4/5/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit

class ForgetPasswordVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var sendNotification: UIButton!
   
    @IBAction func sendNotification(sender: AnyObject) {
        if (self.mobileNumber.text!.isEmpty) {
            
            let alert = UIAlertView()
            alert.title = "Empty field"
            alert.message = "Please enter information in text box"
            alert.addButtonWithTitle("Ok")
            alert.show()
            
        }else{
            
            sendNotification()
            
        }
        
        
    }

    func sendNotification() {
        let url = NSURL 
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
