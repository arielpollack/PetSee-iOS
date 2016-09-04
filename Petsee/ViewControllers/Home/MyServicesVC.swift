//
//  MyServicesVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class MyServicesVC: UIViewController {

    @IBOutlet var servicesTableView: UITableView!
    
    var services = [Service]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadServices()
    }

    private func loadServices() {
        ServicesStore.sharedStore.fetchAll { services in
            self.services = services
            self.servicesTableView.reloadData()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let serviceVC = segue.destinationViewController as? ServiceVC else {
            return
        }
        guard let indexPath = servicesTableView.indexPathForSelectedRow else {
            return
        }
        
        serviceVC.service = services[indexPath.row]
    }
}


extension MyServicesVC: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Service") as! ServiceCell
        cell.service = services[indexPath.row]
        return cell
    }
}

