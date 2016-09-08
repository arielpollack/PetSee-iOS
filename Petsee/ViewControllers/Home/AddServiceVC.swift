//
//  AddServiceVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 04/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import XLForm
import ImagePicker
import SVProgressHUD
import CoreLocation

class AddServiceVC: XLFormViewController {
    
    var service = Service()
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    func initializeForm() {
        let form: XLFormDescriptor = XLFormDescriptor()
        let section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        
        let petRow = XLFormRowDescriptor(tag: "pet", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Pet")
        petRow.required = true
        section.addFormRow(petRow)
        PetsStore.sharedStore.fetchAll { pets in
            petRow.value = pets.first?.name
            petRow.selectorOptions = pets.map { $0.name }  ?? []
        }
        
        var row = XLFormRowDescriptor(tag: "type", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Service Type")
        row.required = true
        row.selectorOptions = ["Dogwalk", "Dogsit"]
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "start_date", rowType: XLFormRowDescriptorTypeDateTime, title: "Start date")
        row.required = true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "end_date", rowType: XLFormRowDescriptorTypeDateTime, title: "End date")
        row.required = true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "location", rowType: XLFormRowDescriptorTypeSelectorPush, title: "Pickup Location")
        row.action.viewControllerClass = SelectLocationVC.self
        row.valueTransformer = CLLocationValueTrasformer.self
        row.required = true
        section.addFormRow(row)
        
        self.form = form
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        let values = form.formValues()
        
        service.startDate = values["start_date"] as! NSDate
        service.endDate = values["end_date"] as! NSDate
        let locationValues = values["location"] as! CLLocation
        let location = Location()
        location.latitude = locationValues.coordinate.latitude
        location.longitude = locationValues.coordinate.longitude
        service.location = location
        
        let typeString = values["type"] as! String
        switch typeString {
        case "Dogwalk":
            service.type = .Walking
        case "Dogsit":
            service.type = .Sitting
        default:
            return
        }
        
        let petName = values["pet"] as! String
        PetsStore.sharedStore.fetchPredicate({ $0.name == petName }) { results in
            guard let pet = results.first else {
                return
            }
            
            self.service.pet = pet
            self.sendToServer()
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func sendToServer() {
        SVProgressHUD.show()
        PetseeAPI.addService(service) { service, error in
            SVProgressHUD.dismiss()
            
            guard let service = service where error == nil else {
                // show error
                return
            }
            
            ServicesStore.sharedStore.add(service)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
