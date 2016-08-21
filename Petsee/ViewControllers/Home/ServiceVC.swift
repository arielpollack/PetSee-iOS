//
//  ServiceVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 20/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import PetseeCore
import PetseeNetwork

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
        case WriteReviewButton
        case CancelButton
        case FindServiceProviderButton
        
        static let PendingCells: [CellType] = [.Status, .StartDate, .EndDate, .FindServiceProviderButton, .CancelButton]
        static let ActiveCells: [CellType] = [.Status, .StartDate, .EndDate, .Type, .TripRoute, .WriteReviewButton]
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
                
            case .CancelButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                return cell
                
            case .FindServiceProviderButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                return cell
                
            case .WriteReviewButton:
                let cell = tableView.dequeueReusableCellWithIdentifier("Button") as! ServiceButtonCell
                return cell
            }
        }
        
        func height() -> CGFloat {
            switch self {
            case .TripRoute:
                return 230
            case .CancelButton, .WriteReviewButton, .FindServiceProviderButton:
                return 60
                
            default:
                return 44
            }
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
    
}