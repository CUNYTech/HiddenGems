//
//  NearbyViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 4/17/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit

class NearbyViewController: UITableViewController {
    
    let totalRows : Int = exploreVenueList.count as Int

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("venuesCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = ((exploreVenueList[indexPath.row]["venue"] as! NSDictionary)["name"] as! String)
        let location = (exploreVenueList[indexPath.row]["venue"] as! NSDictionary)["location"] as! NSDictionary
        //print("LOCATION: " + String(location))
        cell.detailTextLabel?.text = (location["address"] as! String)
        let id = (exploreVenueList[indexPath.row]["venue"] as! NSDictionary)["id"] as! String
        cell.imageView?.image = UIImage(data: exploreImageCache[id]!)
        
        return cell
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
