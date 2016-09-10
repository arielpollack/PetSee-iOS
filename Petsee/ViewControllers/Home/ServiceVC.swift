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

protocol ServiceVCDelegate: NSObjectProtocol {
    func serviceViewControllerDidApprove(controller: ServiceVC, service: Service)
    func serviceViewControllerDidDeny(controller: ServiceVC, service: Service)
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
    private var isClient: Bool = {
        return AuthManager.sharedInstance.authenticatedUser!.type == .Client
    }()
    weak var delegate: ServiceVCDelegate?
    
    var cellTypes = [CellType]()
    
    enum CellType {
        case Status
        case StartDate
        case EndDate
        case Type
        case TripRoute
        case Space
        case WriteReviewButton
        case CancelButton
        case FindServiceProviderButton
        case ApproveButton
        case DenyButton
        case StartService
        case EndService
        case LocationCell
        
        static let BasicCells: [CellType] = [.Status, .Type, .StartDate, .EndDate]
        
        static let dateFormatter: NSDateFormatter = {
            let df = NSDateFormatter()
            df.dateFormat = "dd LLL yy',' HH:mm"
            return df
        }()
        
        func cell(service: Service, tableView: UITableView) -> UITableViewCell {
            switch self {
            case .Status:
                let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
                cell.textLabel?.text = "Status"
                cell.detailTextLabel?.text = service.status.readableString
                cell.detailTextLabel?.textColor = service.status.presentingColor
                return cell
            case .StartDate:
                let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
                cell.textLabel?.text = "Start date"
                cell.detailTextLabel?.text = CellType.dateFormatter.stringFromDate(service.startDate)
                cell.detailTextLabel?.textColor = UIColor.darkTextColor()
                return cell
            case .EndDate:
                let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
                cell.textLabel?.text = "End date"
                cell.detailTextLabel?.text = CellType.dateFormatter.stringFromDate(service.endDate)
                cell.detailTextLabel?.textColor = UIColor.darkTextColor()
                return cell
            case .Type:
                let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
                cell.textLabel?.text = "Type"
                cell.detailTextLabel?.text = service.type.readableString
                cell.detailTextLabel?.textColor = UIColor.darkTextColor()
                return cell
                
            case .TripRoute:
                let cell = tableView.dequeueReusableCellWithIdentifier("Map") as! ServiceTripRouteCell
                cell.service = service
                return cell
                
            case .Space:
                return tableView.dequeueReusableCellWithIdentifier("Space")!
                
            case .CancelButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "c0392b")!
                cell.title = "Cancel Service"
                cell.action = {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.CancelServiceTapped, object: service)
                }
                return cell
                
            case .FindServiceProviderButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "3498db")!
                cell.title = "Find Your \(service.type.readableString)er"
                cell.action = {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.FindServiceProviderTapped, object: service)
                }
                return cell
                
            case .WriteReviewButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "2ecc71")!
                cell.title = "Write a Review"
                cell.action = {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.WriteReviewTapped, object: service)
                }
                return cell
                
            case .ApproveButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "2ecc71")!
                cell.title = "Approve Service Request"
                cell.action = {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ApproveServiceTapped, object: service)
                }
                return cell
                
            case .DenyButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "c0392b")!
                cell.title = "Deny Service Request"
                cell.action = {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.DenyServiceTapped, object: service)
                }
                return cell
                
            case .StartService:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "2ecc71")!
                cell.title = "Start Service"
                cell.action = {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.StartServiceTapped, object: service)
                }
                return cell
                
            case .EndService:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "c0392b")!
                cell.title = "End Service"
                cell.action = {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.EndServiceTapped, object: service)
                }
                return cell
                
            case .LocationCell:
                let cell = tableView.dequeueReusableCellWithIdentifier("Location") as! ServiceLocationCell
                cell.service = service
                return cell
            }
        }
        
        func height() -> CGFloat {
            switch self {
            case .TripRoute, .LocationCell:
                return 230
            case .CancelButton, .WriteReviewButton, .FindServiceProviderButton, .ApproveButton, .DenyButton, .StartService, .EndService:
                return 50
            case .Space:
                return 24
                
            default:
                return 44
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViews()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(findServiceProviderTapped), name: Notification.FindServiceProviderTapped, object: service)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(writeReviewTapped), name: Notification.WriteReviewTapped, object: service)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cancelServiceTapped), name: Notification.CancelServiceTapped, object: service)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(approveServiceRequestTapped), name: Notification.ApproveServiceTapped, object: service)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(denyServiceRequestTapped), name: Notification.DenyServiceTapped, object: service)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startServiceTapped), name: Notification.StartServiceTapped, object: service)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(endServiceTapped), name: Notification.EndServiceTapped, object: service)
        
        loadServiceInfo()
    }
    
    private func loadViews() {
        let user = service.serviceProvider
        lblServiceProviderName.text = user?.name ?? "Not chosen"
        if let image = user?.image {
            let url = NSURL(string: image)!
            imgServiceProvider.af_setImageWithURL(url)
        } else {
            imgServiceProvider.image = UIImage(named: "user_profile_icon")
        }
        
        lblPetName.text = service.pet.name
        
        if let image = service.pet.image {
            let url = NSURL(string: image)!
            imgPet.af_setImageWithURL(url)
        }
    }
    
    private func loadServiceInfo() {
        if isClient {
            // I'm th client
            switch service.status! {
            case .Pending:
                // Did not choose service provider yet
                cellTypes = CellType.BasicCells + [.Space, .FindServiceProviderButton, .CancelButton]
                
            case .Confirmed:
                // Waiting for the service to start on it's date
                cellTypes = CellType.BasicCells + [.Space, .CancelButton]
                
            case .Started, .Ended:
                // In progress / ended
                cellTypes = CellType.BasicCells + [.TripRoute, .Space, .WriteReviewButton]
                
            case .Cancelled:
                cellTypes = CellType.BasicCells
                
            }
        } else {
            // I'm the service provider
            switch service.status! {
            case .Pending:
                // waiting for my confirmation
                cellTypes = CellType.BasicCells + [.LocationCell, .Space, .ApproveButton, .DenyButton]
                
            case .Confirmed:
                // I need to start it
                cellTypes = CellType.BasicCells + [.LocationCell, .Space, .StartService]
                
            case .Started:
                // I need to end it
                cellTypes = CellType.BasicCells + [.TripRoute, .Space, .EndService]
                
            case .Ended:
                // just view the details
                cellTypes = CellType.BasicCells + [.TripRoute, .Space, .WriteReviewButton]
                
            default:
                break
            }
        }
        
        tableView.reloadData()
    }
    
    func findServiceProviderTapped() {
        let vc = UIStoryboard(name: "Client", bundle: nil).instantiateViewControllerWithIdentifier("FindServiceProviderVC") as! FindServiceProviderVC
        vc.service = service
        vc.delegate = self
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func writeReviewTapped() {
        let reviewVC = storyboard?.instantiateViewControllerWithIdentifier("AddReviewVC") as! AddReviewVC
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
            self.navigationController?.popViewControllerAnimated(true)
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
    
    func showError(error: String) {
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType = cellTypes[indexPath.row]
        return cellType.cell(service, tableView: tableView)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
    
    private func loadTripRoute() {
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
    
    private func loadGoogleImage(locations: [Location]) {
        GoogleMapsService.imageMapForLocations(imgTripRoute.bounds.size, locations: locations) { [weak self] image in
            self?.imgTripRoute.image = image
            self?.loader.stopAnimating()
            
            self?.scheduleNextUpdate()
        }
    }
    
    private func scheduleNextUpdate() {
        // if it's ended locations won't be updated anymore
        if service.status == .Ended {
            return
        }
        
        print("scheduled next route reload")
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.loadTripRoute()
        }
    }
}

class ServiceLocationCell: ServiceTripRouteCell {
    
    private override func loadTripRoute() {
        GoogleMapsService.imageMapForLocation(imgTripRoute.bounds.size, location: service.location) { image in
            self.imgTripRoute.image = image
            self.loader.stopAnimating()
        }
    }
}

class ServiceButtonCell: UITableViewCell {
    
    @IBOutlet weak var button: PetseeButton! {
        didSet {
            button.addTarget(self, action: #selector(didTap), forControlEvents: .TouchUpInside)
        }
    }
    
    var title: String? {
        didSet {
            button.setTitle(title, forState: .Normal)
        }
    }
    
    var color: UIColor = UIColor.greenColor() {
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