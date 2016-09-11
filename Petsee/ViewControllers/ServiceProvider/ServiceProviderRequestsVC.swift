//
//  ServiceProviderRequestsVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 09/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import SVProgressHUD

class ServiceProviderRequestsVC: UIViewController {
    
    @IBOutlet weak var tableRequests: UITableView!
    @IBOutlet var emptyStateView: UIView!
    
    private var requests = [ServiceRequest]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        PetseeAPI.myServiceRequests { requests, error in
            guard let requests = requests where error == nil else {
                // handle error
                return
            }
            
            self.requests = requests
            self.tableRequests.reloadData()
            
            self.showEmptyStateIfNeeded()
        }
    }
    
    @IBAction func closeTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func approveServiceRequest(request: ServiceRequest, completion: Bool->() = { _ in }) {
        SVProgressHUD.show()
        PetseeAPI.approveServiceRequest(request) { _, error in
            SVProgressHUD.dismiss()
            if let _ = error {
                completion(false)
            } else {
                completion(true)
                self.removeRequestFromTableView(request)
            }
        }
    }
    
    func denyServiceRequest(request: ServiceRequest, completion: Bool->() = { _ in }) {
        SVProgressHUD.show()
        PetseeAPI.denyServiceRequest(request) { _, error in
            SVProgressHUD.dismiss()
            if let _ = error {
                completion(false)
            } else {
                completion(true)
                self.removeRequestFromTableView(request)
            }
        }
    }
    
    func removeRequestFromTableView(request: ServiceRequest) {
        guard let index = requests.indexOf(request) else {
            return
        }
        
        requests.removeAtIndex(index)
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        tableRequests.beginUpdates()
        tableRequests.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableRequests.endUpdates()
        
        showEmptyStateIfNeeded()
    }
    
    private func showEmptyStateIfNeeded() {
        if requests.count == 0 {
            tableRequests.backgroundView = emptyStateView
        } else {
            tableRequests.backgroundView = nil
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
        cell.delegate = self
        return cell
    }
}

extension ServiceProviderRequestsVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let request = requests[indexPath.row]
        let serviceVC = storyboard?.instantiateViewControllerWithIdentifier("ServiceVC") as! ServiceVC
        serviceVC.service = request.service!
        serviceVC.delegate = self
        navigationController?.pushViewController(serviceVC, animated: true)
    }
}

extension ServiceProviderRequestsVC: ServiceRequestCellDelegate {
    func didApproveServiceRequest(request: ServiceRequest) {
        approveServiceRequest(request)
    }
    
    func didDenyServiceRequest(request: ServiceRequest) {
        denyServiceRequest(request)
    }
}

extension ServiceProviderRequestsVC: ServiceVCDelegate {
    
    private func serviceRequestForService(service: Service) -> ServiceRequest? {
        let services = requests.map { $0.service! }
        if let index = services.indexOf(service) {
            return requests[index]
        }
        return nil
    }
    
    func serviceViewControllerDidApprove(controller: ServiceVC, service: Service) {
        guard let request = serviceRequestForService(service) else {
            navigationController?.popViewControllerAnimated(true)
            return
        }
        
        approveServiceRequest(request) { success in
            if success {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                controller.showError("Couldn't approve service request")
            }
        }
    }
    
    func serviceViewControllerDidDeny(controller: ServiceVC, service: Service) {
        guard let request = serviceRequestForService(service) else {
            navigationController?.popViewControllerAnimated(true)
            return
        }
        
        denyServiceRequest(request) { success in
            if success {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                controller.showError("Couldn't deny service request")
            }
        }
    }
}