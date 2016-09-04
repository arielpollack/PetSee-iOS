//
//  ServiceVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 20/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import AlamofireImage

class ServiceVC: UITableViewController {
    
    @IBOutlet weak var imgServiceProvider: UIImageView!
    @IBOutlet weak var imgPet: UIImageView!
    @IBOutlet weak var lblServiceProviderName: UILabel!
    @IBOutlet weak var lblPetName: UILabel!
 
    var service: Service!
    
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
        
        static let PendingCells: [CellType] = [.Status, .StartDate, .EndDate, .Space, .FindServiceProviderButton, .CancelButton]
        static let ActiveCells: [CellType] = [.Status, .StartDate, .EndDate, .Type, .TripRoute, .Space, .WriteReviewButton]
        static let CancelledCells: [CellType] = [.Status, .Type, .StartDate, .EndDate]
        
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
                return cell
                
            case .FindServiceProviderButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "3498db")!
                cell.title = "Find Your Dogwalker"
                cell.action = {
                    let vc = UIStoryboard(name: "Client", bundle: nil).instantiateViewControllerWithIdentifier("FindServiceProviderVC") as! FindServiceProviderVC
                    vc.service = service
                    if let destVC = UIViewController.topMostViewController() {
                        if let navController = destVC as? UINavigationController {
                            navController.pushViewController(vc, animated: true)
                        } else if let navController = destVC.navigationController {
                            navController.pushViewController(vc, animated: true)
                        } else {
                            destVC.presentViewController(vc, animated: true, completion: nil)
                        }
                    }
                }
                return cell
                
            case .WriteReviewButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                cell.color = UIColor(hex: "2ecc71")!
                cell.title = "Write a Review"
                return cell
            }
        }
        
        func height() -> CGFloat {
            switch self {
            case .TripRoute:
                return 230
            case .CancelButton, .WriteReviewButton, .FindServiceProviderButton:
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
    }
    
    private func loadViews() {
        lblServiceProviderName.text = service.serviceProvider?.name ?? "Not chosen"
        lblPetName.text = service.pet.name
        if let image = service.serviceProvider?.image {
            let url = NSURL(string: image)!
            imgServiceProvider.af_setImageWithURL(url)
        } else {
            imgServiceProvider.image = UIImage(named: "question_mark")
        }
        if let image = service.pet.image {
            let url = NSURL(string: image)!
            imgPet.af_setImageWithURL(url)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch service.status! {
        case .Pending:
            return CellType.PendingCells.count
        case .Started, .Ended:
            return CellType.ActiveCells.count
        case .Cancelled:
            return CellType.CancelledCells.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType: CellType
        
        switch service.status! {
        case .Pending:
            cellType = CellType.PendingCells[indexPath.row]
        case .Started, .Ended:
            cellType = CellType.ActiveCells[indexPath.row]
        case .Cancelled:
            cellType = CellType.CancelledCells[indexPath.row]
        }
        
        return cellType.cell(service, tableView: tableView)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType: CellType
        
        switch service.status! {
        case .Pending:
            cellType = CellType.PendingCells[indexPath.row]
        case .Started, .Ended:
            cellType = CellType.ActiveCells[indexPath.row]
        case .Cancelled:
            cellType = CellType.CancelledCells[indexPath.row]
        }
        
        return cellType.height()
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
        PetseeAPI.locationsForService(service) { locations, error in
            if let locations = locations {
                self.loadGoogleImage(locations)
            } else {
                self.loader.stopAnimating()
            }
        }
    }
    
    private func loadGoogleImage(locations: [Location]) {
        GoogleMapsService.imageMapForLocations(imgTripRoute.bounds.size, locations: locations) { image in
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



















