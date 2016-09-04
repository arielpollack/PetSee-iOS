//
//  FindServiceProviderVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 04/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import PetseeCore
import PetseeNetwork
import AlamofireImage
import HCSStarRatingView
import SVProgressHUD

protocol ServiceProviderCellDelegate: NSObjectProtocol {
    func sendRequestForServiceProvider(provider: ServiceProvider)
}

class ServiceProviderCell: UITableViewCell {
    
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblReviewsCount: UILabel!
    @IBOutlet weak var ratingStars: HCSStarRatingView!
    @IBOutlet weak var btnSendRequest: UIButton!
    
    var serviceProvider: ServiceProvider! {
        didSet {
            loadServiceProviderInfo()
        }
    }
    var serviceRequest: ServiceRequest? {
        didSet {
            loadServiceRequestInfo()
        }
    }
    
    weak var delegate: ServiceProviderCellDelegate?
    
    private func loadServiceProviderInfo() {
        lblName.text = serviceProvider.name
        ratingStars.value = CGFloat(serviceProvider.rating ?? 0)
        lblReviewsCount.text = "(\(serviceProvider.ratingCount ?? 0) reviews)"
        if let image = serviceProvider.image, url = NSURL(string: image) {
            imgThumbnail.af_setImageWithURL(url)
        } else {
            imgThumbnail.af_cancelImageRequest()
            imgThumbnail.image = nil
        }
    }
    
    private func loadServiceRequestInfo() {
        if let request = serviceRequest {
            btnSendRequest.setTitle(request.status.readableString, forState: .Normal)
            btnSendRequest.enabled = false
        } else {
            btnSendRequest.setTitle("Send Request", forState: .Normal)
            btnSendRequest.enabled = true
        }
    }
    
    @IBAction func sendRequestTapped() {
        delegate?.sendRequestForServiceProvider(serviceProvider)
    }
}

class FindServiceProviderVC: UIViewController {
    
    var service: Service!
    
    private var serviceRequests = [ServiceRequest]()
    private var serviceProviders = [ServiceProvider]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadServiceProvidersAndRequests()
    }
    
    private func loadServiceProvidersAndRequests() {
        PetseeAPI.getServiceRequests(service) { requests, error in
            guard let requests = requests where error == nil else {
                // show error
                return
            }
            
            self.serviceRequests = requests
            self.tableView.reloadData()
        }
        
        PetseeAPI.getAvailableServiceProviders(service) { providers, error in
            guard let providers = providers where error == nil else {
                // show error
                return
            }
            
            self.serviceProviders = providers
            self.tableView.reloadData()
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
            return serviceRequests.count
        }
        
        return serviceProviders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceProvider") as! ServiceProviderCell
        cell.delegate = self
        
        if indexPath.section == 1 || !haveServiceRequests() {
            let request = serviceRequests[indexPath.row]
            cell.serviceRequest = request
            cell.serviceProvider = request.serviceProvider
        } else {
            let provider = serviceProviders[indexPath.row]
            cell.serviceProvider = provider
            cell.serviceRequest = nil
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
    
    private func addServiceRequest(request: ServiceRequest) {
        tableView.beginUpdates()
        
        if let index = serviceProviders.indexOf(request.serviceProvider) {
            tableView.moveRowAtIndexPath(NSIndexPath(forRow: index, inSection: 1), toIndexPath: NSIndexPath(forRow: serviceRequests.count, inSection: 0))
            serviceProviders.removeAtIndex(index)
        } else {
            let indexPath = NSIndexPath(forRow: serviceRequests.count, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    
        serviceRequests.append(request)
        tableView.endUpdates()
    }
}