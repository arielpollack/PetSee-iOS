//
//  ServiceProviderRequestsVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 09/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class ServiceProviderRequestsVC: UIViewController {
    
    @IBOutlet weak var tableRequests: UITableView!
    
    private var requests = [ServiceRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PetseeAPI.myServiceRequests { requests, error in
            guard let requests = requests where error == nil else {
                // handle error
                return
            }
            
            self.requests = requests
            self.tableRequests.reloadData()
        }
    }
}

extension ServiceProviderRequestsVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceRequest") as! ServiceRequestCell
        cell.serviceRequest = requests[indexPath.row]
        return cell
    }
}

extension ServiceProviderRequestsVC: UITableViewDelegate {
    
}