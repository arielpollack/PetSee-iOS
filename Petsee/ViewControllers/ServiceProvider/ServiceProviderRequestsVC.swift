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
    
    fileprivate var requests = [ServiceRequest]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PetseeAPI.myServiceRequests { requests, error in
            guard let requests = requests, error == nil else {
                // handle error
                return
            }
            
            self.requests = requests
            self.tableRequests.reloadData()
            
            self.showEmptyStateIfNeeded()
        }
    }
    
    @IBAction func closeTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func approveServiceRequest(_ request: ServiceRequest, completion: @escaping (Bool)->() = { _ in }) {
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
    
    func denyServiceRequest(_ request: ServiceRequest, completion: @escaping (Bool)->() = { _ in }) {
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
    
    func removeRequestFromTableView(_ request: ServiceRequest) {
        guard let index = requests.index(of: request) else {
            return
        }
        
        requests.remove(at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tableRequests.beginUpdates()
        tableRequests.deleteRows(at: [indexPath], with: .fade)
        tableRequests.endUpdates()
        
        showEmptyStateIfNeeded()
    }
    
    fileprivate func showEmptyStateIfNeeded() {
        if requests.count == 0 {
            tableRequests.backgroundView = emptyStateView
        } else {
            tableRequests.backgroundView = nil
        }
    }
}

extension ServiceProviderRequestsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceRequest") as! ServiceRequestCell
        cell.serviceRequest = requests[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension ServiceProviderRequestsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = requests[indexPath.row]
        let serviceVC = storyboard?.instantiateViewController(withIdentifier: "ServiceVC") as! ServiceVC
        serviceVC.service = request.service!
        serviceVC.delegate = self
        navigationController?.pushViewController(serviceVC, animated: true)
    }
}

extension ServiceProviderRequestsVC: ServiceRequestCellDelegate {
    func didApproveServiceRequest(_ request: ServiceRequest) {
        approveServiceRequest(request)
    }
    
    func didDenyServiceRequest(_ request: ServiceRequest) {
        denyServiceRequest(request)
    }
}

extension ServiceProviderRequestsVC: ServiceVCDelegate {
    
    fileprivate func serviceRequestForService(_ service: Service) -> ServiceRequest? {
        let services = requests.map { $0.service! }
        if let index = services.index(of: service) {
            return requests[index]
        }
        return nil
    }
    
    func serviceViewControllerDidApprove(_ controller: ServiceVC, service: Service) {
        guard let request = serviceRequestForService(service) else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        approveServiceRequest(request) { success in
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                controller.showError("Couldn't approve service request")
            }
        }
    }
    
    func serviceViewControllerDidDeny(_ controller: ServiceVC, service: Service) {
        guard let request = serviceRequestForService(service) else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        denyServiceRequest(request) { success in
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                controller.showError("Couldn't deny service request")
            }
        }
    }
}
