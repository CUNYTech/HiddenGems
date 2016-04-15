//
//  ExploreViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 3/1/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

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
        
        displayUsername.text = "welcome, " + receivedUser
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
    

    }
    
    
    @IBAction func logoutButton(sender: UIButton) {
        
        /*
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
        
*/
        
    }


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
    

}
