//
//  RaceChooseVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 03/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import XLForm
import PetseeCore
import PetseeNetwork
import AlamofireImage

class RaceChooseVC: UITableViewController, XLFormRowDescriptorViewController {

    var rowDescriptor: XLFormRowDescriptor!
    
    private var races = [Race]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRaces()
    }
    
    private func fetchRaces(term term: String? = nil) {
        PetseeAPI.fetchRaces(term ?? "") { races, error in
            guard let races = races else {
                self.races = []
                self.tableView.reloadData()
                return
            }
            
            self.races = races
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return races.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Race")!
        
        let race = races[indexPath.row]
        cell.textLabel?.text = race.name
        cell.imageView?.af_setImageWithURL(NSURL(string: race.image)!)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rowDescriptor.value = races[indexPath.row]
        navigationController?.popViewControllerAnimated(true)
    }
}

class RaceFormValueTransformer: NSValueTransformer {
  
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let value = value as? Race else {
            return nil
        }
        
        return value.name
    }
}