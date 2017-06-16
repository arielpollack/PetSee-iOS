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
    
    fileprivate var serviceRequests = [ServiceRequest]()
    fileprivate var serviceProviders = [ServiceProvider]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Find a \(service.type.readableString)er"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadServiceProvidersAndRequests()
    }
    
    fileprivate func loadServiceProvidersAndRequests() {
        PetseeAPI.getAvailableServiceProviders(service) { providers, error in
            guard let providers = providers, error == nil else {
                // show error
                return
            }
            
            self.serviceProviders = providers
            self.loadServiceRequests()
        }
    }
    
    fileprivate func loadServiceRequests() {
        PetseeAPI.getServiceRequests(service) { requests, error in
            guard let requests = requests, error == nil else {
                // show error
                return
            }
            
            self.serviceRequests = requests
            self.filterApproachedServiceProviders()
            self.tableView.reloadData()
        }
    }
    
    fileprivate func filterApproachedServiceProviders() {
        for request in serviceRequests {
            if let index = serviceProviders.index(of: request.serviceProvider) {
                serviceProviders.remove(at: index)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserProfile, let indexPath = tableView.indexPathForSelectedRow {
            if indexPath.section == 1 || !haveServiceRequests() {
                vc.user = serviceProviders[indexPath.row]
            } else {
                vc.user = serviceRequests[indexPath.row].serviceProvider
            }
        }
    }
}

extension FindServiceProviderVC: UITableViewDataSource {
    
    fileprivate func haveServiceRequests() -> Bool {
        return serviceRequests.count > 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return haveServiceRequests() ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || !haveServiceRequests() {
            return serviceProviders.count
        }
        
        return serviceRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceProvider") as! ServiceProviderCell
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 || !haveServiceRequests() {
            return "Available Service Providers"
        }
        
        return "Approached Service Providers"
    }
}

extension FindServiceProviderVC: ServiceProviderCellDelegate {
    
    func sendRequestForServiceProvider(_ provider: ServiceProvider) {
        SVProgressHUD.show()
        PetseeAPI.requestServiceProvider(service, serviceProvider: provider) { request, error in
            SVProgressHUD.dismiss()
            
            guard let request = request, error == nil else {
                // show error
                return
            }
            
            self.addServiceRequest(request)
        }
    }
    
    func chooseServiceRequest(_ request: ServiceRequest) {
        PetseeAPI.chooseServiceRequest(service, serviceRequest: request) { object, error in
            guard error == nil else {
                // show error
                return
            }
            
            self.service.serviceProvider = request.serviceProvider
            self.service.status = .Confirmed
            ServicesStore.sharedStore.replace(self.service)
            
            self.delegate?.didChooseServiceProvider()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func addServiceRequest(_ request: ServiceRequest) {
        if let index = serviceProviders.index(of: request.serviceProvider) {
            serviceProviders.remove(at: index)
        }
    
        serviceRequests.append(request)
        tableView.reloadData()
    }
}
