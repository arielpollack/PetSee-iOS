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
    fileprivate lazy var inboxView = InboxView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
    
    var services = [Service]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AuthManager.sharedInstance.authenticatedUser!.type == .ServiceProvider {
            self.inboxView.setAction(self, action: #selector(inboxTapped))
            let button = UIBarButtonItem(customView: inboxView)
            navigationItem.leftBarButtonItem = button
            
            PetseeAPI.myServiceRequests({ requests, error in
                guard let requests = requests, error == nil else {
                    return
                }
                
                self.inboxView.setBadgeCount(requests.count)
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AuthManager.sharedInstance.authenticatedUser!.type == .ServiceProvider {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // reload from server
        ServicesStore.sharedStore.loadObjects()
        
        // load from local storage
        loadServices()
    }

    fileprivate func loadServices() {
        ServicesStore.sharedStore.fetchAll { services in
            self.services = services
            self.servicesTableView.reloadData()
        }
    }
    
    func inboxTapped() {
        let requestsVC = storyboard!.instantiateViewController(withIdentifier: "ServiceRequests")
        present(requestsVC, animated: true, completion: {
            self.inboxView.setBadgeCount(0)
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let serviceVC = segue.destination as? ServiceVC else {
            return
        }
        guard let indexPath = servicesTableView.indexPathForSelectedRow else {
            return
        }
        
        serviceVC.service = services[indexPath.row]
    }
}


extension MyServicesVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Service") as! ServiceCell
        cell.service = services[indexPath.row]
        return cell
    }
}
