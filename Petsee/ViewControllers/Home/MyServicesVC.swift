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
    private lazy var inboxView = InboxView(frame: CGRectMake(0, 0, 35, 35))
    
    var services = [Service]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AuthManager.sharedInstance.authenticatedUser!.type == .ServiceProvider {
            self.inboxView.setAction(self, action: #selector(inboxTapped))
            let button = UIBarButtonItem(customView: inboxView)
            navigationItem.leftBarButtonItem = button
            
            PetseeAPI.myServiceRequests({ requests, error in
                guard let requests = requests where error == nil else {
                    return
                }
                
                self.inboxView.setBadgeCount(requests.count)
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if AuthManager.sharedInstance.authenticatedUser!.type == .ServiceProvider {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // reload from server
        ServicesStore.sharedStore.loadObjects()
        
        // load from local storage
        loadServices()
    }

    private func loadServices() {
        ServicesStore.sharedStore.fetchAll { services in
            self.services = services
            self.servicesTableView.reloadData()
        }
    }
    
    func inboxTapped() {
        let requestsVC = storyboard!.instantiateViewControllerWithIdentifier("ServiceRequests")
        presentViewController(requestsVC, animated: true, completion: {
            self.inboxView.setBadgeCount(0)
        })
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