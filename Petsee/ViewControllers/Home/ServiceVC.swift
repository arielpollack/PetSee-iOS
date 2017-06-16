//
//  ServiceVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 20/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import AlamofireImage
import SVProgressHUD
import CoreLocation

protocol ServiceVCDelegate: NSObjectProtocol {
    func serviceViewControllerDidApprove(_ controller: ServiceVC, service: Service)
    func serviceViewControllerDidDeny(_ controller: ServiceVC, service: Service)
}

class ServiceVC: UITableViewController {
    
    struct Notification {
        static let FindServiceProviderTapped = "ShowFindServiceProviderTappedNotification"
        static let WriteReviewTapped = "WriteReviewTappedNotification"
        static let CancelServiceTapped = "CancelServiceTappedNotification"
        static let ApproveServiceTapped = "ApproveServiceTappedNotification"
        static let DenyServiceTapped = "DenyServiceTappedNotification"
        static let StartServiceTapped = "StartServiceTappedNotification"
        static let EndServiceTapped = "EndServiceTappedNotification"
    }
    
    @IBOutlet weak var imgServiceProvider: UIImageView!
    @IBOutlet weak var imgPet: UIImageView!
    @IBOutlet weak var lblServiceProviderName: UILabel!
    @IBOutlet weak var lblPetName: UILabel!
 
    var service: Service!
    fileprivate var isClient: Bool = {
        return AuthManager.sharedInstance.authenticatedUser!.type == .Client
    }()
    weak var delegate: ServiceVCDelegate?
    var showServiceProvidersOnOpen = false
    
    var cellTypes = [CellType]()
    
    enum CellType {
        case status
        case startDate
        case endDate
        case type
        case address
        case tripRoute
        case distance
        case space
        case writeReviewButton
        case cancelButton
        case findServiceProviderButton
        case approveButton
        case denyButton
        case startService
        case endService
        case locationCell
        
        static let BasicCells: [CellType] = [.status, .type, .startDate, .endDate]
        
        static let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "dd LLL yy',' HH:mm"
            return df
        }()
        
        func cell(_ service: Service, tableView: UITableView) -> UITableViewCell {
            switch self {
            case .status:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.textLabel?.text = "Status"
                cell.detailTextLabel?.text = service.status.readableString
                cell.detailTextLabel?.textColor = service.status.presentingColor
                return cell
            case .startDate:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.textLabel?.text = "Start date"
                cell.detailTextLabel?.text = CellType.dateFormatter.string(from: service.startDate as Date)
                cell.detailTextLabel?.textColor = UIColor.darkText
                return cell
            case .endDate:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.textLabel?.text = "End date"
                cell.detailTextLabel?.text = CellType.dateFormatter.string(from: service.endDate as Date)
                cell.detailTextLabel?.textColor = UIColor.darkText
                return cell
            case .type:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.textLabel?.text = "Type"
                cell.detailTextLabel?.text = service.type.readableString
                cell.detailTextLabel?.textColor = UIColor.darkText
                return cell
                
            case .address:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.textLabel?.text = "Address"
                cell.detailTextLabel?.text = service.location.address
                cell.detailTextLabel?.textColor = UIColor.darkText
                return cell
                
            case .distance:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.textLabel?.text = "Distance"
                cell.detailTextLabel?.text = "0km"
                cell.detailTextLabel?.textColor = UIColor.darkText
                PetseeAPI.locationsForService(service, completion: { [weak cell] (locations, error) in
                    guard let locations = locations, locations.count > 0 else {
                        return
                    }
                    
                    let distance = locations.reduce(["sum": Int(0), "loc": locations.first!], { obj, location in
                        var sum = obj["sum"] as! Int
                        let lastLocation = obj["loc"] as! Location
                        let coord1 = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
                        let coord2 = CLLocation(latitude: location.latitude, longitude: location.longitude)
                        sum += Int(coord2.distance(from: coord1))
                        return ["sum": sum, "loc": location]
                    })["sum"] as! Int
                    
                    cell?.detailTextLabel?.text = "\(Double(distance) / 1000)km"
                })
                return cell
                
            case .tripRoute:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Map") as! ServiceTripRouteCell
                cell.service = service
                return cell
                
            case .space:
                return tableView.dequeueReusableCell(withIdentifier: "Space")!
                
            case .cancelButton:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "c0392b")!
                cell.title = "Cancel Service"
                cell.action = {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.CancelServiceTapped), object: service)
                }
                return cell
                
            case .findServiceProviderButton:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "3498db")!
                cell.title = "Find Your \(service.type.readableString)er"
                cell.action = {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.FindServiceProviderTapped), object: service)
                }
                return cell
                
            case .writeReviewButton:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "2ecc71")!
                cell.title = "Write a Review"
                cell.action = {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.WriteReviewTapped), object: service)
                }
                return cell
                
            case .approveButton:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "2ecc71")!
                cell.title = "Approve Request"
                cell.action = {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.ApproveServiceTapped), object: service)
                }
                return cell
                
            case .denyButton:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "c0392b")!
                cell.title = "Deny Request"
                cell.action = {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.DenyServiceTapped), object: service)
                }
                return cell
                
            case .startService:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "2ecc71")!
                cell.title = "Start Service"
                cell.action = {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.StartServiceTapped), object: service)
                }
                return cell
                
            case .endService:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "c0392b")!
                cell.title = "End Service"
                cell.action = {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.EndServiceTapped), object: service)
                }
                return cell
                
            case .locationCell:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Location") as! ServiceLocationCell
                cell.service = service
                return cell
            }
        }
        
        func height() -> CGFloat {
            switch self {
            case .tripRoute, .locationCell:
                return 230
            case .cancelButton, .writeReviewButton, .findServiceProviderButton, .approveButton, .denyButton, .startService, .endService:
                return 50
            case .space:
                return 24
                
            default:
                return 44
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(findServiceProviderTapped), name: NSNotification.Name(rawValue: Notification.FindServiceProviderTapped), object: service)
        NotificationCenter.default.addObserver(self, selector: #selector(writeReviewTapped), name: NSNotification.Name(rawValue: Notification.WriteReviewTapped), object: service)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelServiceTapped), name: NSNotification.Name(rawValue: Notification.CancelServiceTapped), object: service)
        NotificationCenter.default.addObserver(self, selector: #selector(approveServiceRequestTapped), name: NSNotification.Name(rawValue: Notification.ApproveServiceTapped), object: service)
        NotificationCenter.default.addObserver(self, selector: #selector(denyServiceRequestTapped), name: NSNotification.Name(rawValue: Notification.DenyServiceTapped), object: service)
        NotificationCenter.default.addObserver(self, selector: #selector(startServiceTapped), name: NSNotification.Name(rawValue: Notification.StartServiceTapped), object: service)
        NotificationCenter.default.addObserver(self, selector: #selector(endServiceTapped), name: NSNotification.Name(rawValue: Notification.EndServiceTapped), object: service)
        
        loadServiceInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if showServiceProvidersOnOpen {
            showServiceProvidersOnOpen = false
            findServiceProviderTapped()
        }
    }
    
    fileprivate func loadViews() {
        let user = service.serviceProvider
        lblServiceProviderName.text = user?.name ?? "Not chosen"
        if let image = user?.image {
            let url = URL(string: image)!
            imgServiceProvider.af_setImage(withURL: url)
        } else {
            imgServiceProvider.image = UIImage(named: "user_profile_icon")
        }
        
        lblPetName.text = service.pet.name
        
        if let image = service.pet.image {
            let url = URL(string: image)!
            imgPet.af_setImage(withURL: url)
        }
    }
    
    fileprivate func loadServiceInfo() {
        let maybeAddress: [CellType]
        if let _ = service.location.address {
            maybeAddress = [.address]
        } else {
            maybeAddress = []
        }
        if isClient {
            // I'm th client
            switch service.status! {
            case .Pending:
                // Did not choose service provider yet
                cellTypes = CellType.BasicCells + maybeAddress + [.space, .findServiceProviderButton, .cancelButton]
                
            case .Confirmed:
                // Waiting for the service to start on it's date
                cellTypes = CellType.BasicCells + maybeAddress + [.space, .cancelButton]
                
            case .Started, .Ended:
                // In progress / ended
                cellTypes = CellType.BasicCells + maybeAddress + [.tripRoute, .distance, .space, .writeReviewButton]
                
            case .Cancelled:
                cellTypes = CellType.BasicCells + maybeAddress
                
            }
        } else {
            // I'm the service provider
            switch service.status! {
            case .Pending:
                // waiting for my confirmation
                cellTypes = CellType.BasicCells + maybeAddress + [.locationCell, .space, .approveButton, .denyButton]
                
            case .Confirmed:
                // I need to start it
                cellTypes = CellType.BasicCells + maybeAddress + [.locationCell, .space, .startService]
                
            case .Started:
                // I need to end it
                cellTypes = CellType.BasicCells + maybeAddress + [.tripRoute, .distance, .space, .endService]
                
            case .Ended:
                // just view the details
                cellTypes = CellType.BasicCells + maybeAddress + [.tripRoute, .distance, .space, .writeReviewButton]
                
            default:
                break
            }
        }
        
        tableView.reloadData()
    }
    
    func findServiceProviderTapped() {
        let vc = UIStoryboard(name: "Client", bundle: nil).instantiateViewController(withIdentifier: "FindServiceProviderVC") as! FindServiceProviderVC
        vc.service = service
        vc.delegate = self
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func writeReviewTapped() {
        let reviewVC = storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
        reviewVC.user = isClient ? service.serviceProvider! : service.client
        navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    func cancelServiceTapped() {
        SVProgressHUD.show()
        PetseeAPI.cancelService(service) { _, error in
            SVProgressHUD.dismiss()
            guard error == nil else {
                // show error
                return
            }
            
            ServicesStore.sharedStore.remove(self.service)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func approveServiceRequestTapped() {
        delegate?.serviceViewControllerDidApprove(self, service: service)
    }
    
    func denyServiceRequestTapped() {
        delegate?.serviceViewControllerDidDeny(self, service: service)
    }
    
    func startServiceTapped() {
        PetseeAPI.startService(service) { _, error in
            guard error == nil else {
                // TODO: show error
                return
            }
            
            self.service.status = .Started
            self.loadServiceInfo()
            
            // start location tracking
            LocationHandler.sharedManager.startTrackingService(self.service)
        }
    }
    
    func endServiceTapped() {
        PetseeAPI.endService(service) { _, error in
            guard error == nil else {
                // TODO: show error
                return
            }
            
            self.service.status = .Ended
            self.loadServiceInfo()
            
            // start location tracking
            LocationHandler.sharedManager.stopTrackingService(self.service)
        }
    }
    
    func showError(_ error: String) {
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cellTypes[indexPath.row]
        return cellType.cell(service, tableView: tableView)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellTypes[indexPath.row]
        return cellType.height()
    }
}

extension ServiceVC: FindServiceProviderVCDelegate {
    
    func didChooseServiceProvider() {
        loadViews()
        loadServiceInfo()
    }
}

class ServiceTripRouteCell: UITableViewCell {
    
    @IBOutlet weak var imgTripRoute: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var service: Service! {
        didSet {
            self.loadTripRoute()
        }
    }
    
    fileprivate func loadTripRoute() {
        PetseeAPI.locationsForService(service) { [weak self] locations, error in
            if let locations = locations {
                if locations.count > 0 {
                    self?.loadGoogleImage(locations)
                } else {
                    self?.loadGoogleImage([self!.service.location])
                }
            } else {
                self?.loader.stopAnimating()
            }
        }
    }
    
    fileprivate func loadGoogleImage(_ locations: [Location]) {
        GoogleMapsService.imageMapForLocations(imgTripRoute.bounds.size, locations: locations) { [weak self] image in
            self?.imgTripRoute.image = image
            self?.loader.stopAnimating()
            
            self?.scheduleNextUpdate()
        }
    }
    
    fileprivate func scheduleNextUpdate() {
        // if it's ended locations won't be updated anymore
        if service.status == .Ended {
            return
        }
        
        print("scheduled next route reload")
        
        let time = DispatchTime.now() + Double(Int64(10 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.loadTripRoute()
        }
    }
}

class ServiceLocationCell: ServiceTripRouteCell {
    
    fileprivate override func loadTripRoute() {
        GoogleMapsService.imageMapForLocation(imgTripRoute.bounds.size, location: service.location) { image in
            self.imgTripRoute.image = image
            self.loader.stopAnimating()
        }
    }
}

class ServiceButtonCell: UITableViewCell {
    
    @IBOutlet weak var button: PetseeButton! {
        didSet {
            button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
            button.layer.cornerRadius = button.bounds.height / 2
//            button.layer.masksToBounds = true
        }
    }
    
    var title: String? {
        didSet {
            button.setTitle(title, for: UIControlState())
        }
    }
    
    var color: UIColor = UIColor.green {
        didSet {
            button.color = color
        }
    }
    
    var action: (() -> ())?
    
    func didTap() {
        action?()
    }
    
    override func prepareForReuse() {
        action = nil
    }
}
