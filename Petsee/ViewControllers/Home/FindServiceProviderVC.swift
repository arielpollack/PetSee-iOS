//
//  FindServiceProviderVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 04/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import AlamofireImage
import SVProgressHUD

protocol FindServiceProviderVCDelegate: NSObjectProtocol {
    func didChooseServiceProvider()
}

class FindServiceProviderVC: UIViewController {
    
    var service: Service!
    weak var delegate: FindServiceProviderVCDelegate?
    
    private var serviceRequests = [ServiceRequest]()
    private var serviceProviders = [ServiceProvider]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadServiceProvidersAndRequests()
    }
    
    private func loadServiceProvidersAndRequests() {
        PetseeAPI.getAvailableServiceProviders(service) { providers, error in
            guard let providers = providers where error == nil else {
                // show error
                return
            }
            
            self.serviceProviders = providers
            self.loadServiceRequests()
        }
    }
    
    private func loadServiceRequests() {
        PetseeAPI.getServiceRequests(service) { requests, error in
            guard let requests = requests where error == nil else {
                // show error
                return
            }
            
            self.serviceRequests = requests
            self.filterApproachedServiceProviders()
            self.tableView.reloadData()
        }
    }
    
    private func filterApproachedServiceProviders() {
        for request in serviceRequests {
            if let index = serviceProviders.indexOf(request.serviceProvider) {
                serviceProviders.removeAtIndex(index)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserProfile, let indexPath = tableView.indexPathForSelectedRow {
            if indexPath.section == 1 || !haveServiceRequests() {
                vc.user = serviceProviders[indexPath.row]
            } else {
                vc.user = serviceRequests[indexPath.row].serviceProvider
            }
        }
    }
}

extension FindServiceProviderVC: UITableViewDataSource {
    
    private func haveServiceRequests() -> Bool {
        return serviceRequests.count > 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return haveServiceRequests() ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || !haveServiceRequests() {
            return serviceProviders.count
        }
        
        return serviceRequests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceProvider") as! ServiceProviderCell
        cell.delegate = self
        
        if indexPath.section == 1 || !haveServiceRequests() {
            let provider = serviceProviders[indexPath.row]
            cell.serviceProvider = provider
            cell.serviceRequest = nil
        } else {
            let request = serviceRequests[indexPath.row]
            cell.serviceRequest = request
            cell.serviceProvider = request.serviceProvider
        }
        
        return cell
    }
}

extension FindServiceProviderVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 || !haveServiceRequests() {
            return "Available Service Providers"
        }
        
        return "Approached Service Providers"
    }
}

extension FindServiceProviderVC: ServiceProviderCellDelegate {
    
    func sendRequestForServiceProvider(provider: ServiceProvider) {
        SVProgressHUD.show()
        PetseeAPI.requestServiceProvider(service, serviceProvider: provider) { request, error in
            SVProgressHUD.dismiss()
            
            guard let request = request where error == nil else {
                // show error
                return
            }
            
            self.addServiceRequest(request)
        }
    }
    
    func chooseServiceRequest(request: ServiceRequest) {
        PetseeAPI.chooseServiceRequest(service, serviceRequest: request) { object, error in
//            guard error == nil else {
//                // show error
//                return
//            }
            
            self.service.serviceProvider = request.serviceProvider
            self.service.status = .Confirmed
            ServicesStore.sharedStore.replace(self.service)
            
            self.delegate?.didChooseServiceProvider()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    private func addServiceRequest(request: ServiceRequest) {
        if let index = serviceProviders.indexOf(request.serviceProvider) {
            serviceProviders.removeAtIndex(index)
        }
    
        serviceRequests.append(request)
        tableView.reloadData()
    }
}