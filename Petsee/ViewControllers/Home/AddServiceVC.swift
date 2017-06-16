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
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    func initializeForm() {
        let form: XLFormDescriptor = XLFormDescriptor()
        let section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        
        let petRow = XLFormRowDescriptor(tag: "pet", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Pet")
        petRow.isRequired = true
        section.addFormRow(petRow)
        PetsStore.sharedStore.fetchAll { pets in
            petRow.value = pets.first?.name
            petRow.selectorOptions = pets.map { $0.name }  
            self.updateFormRow(petRow)
        }
        
        var row = XLFormRowDescriptor(tag: "type", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Service Type")
        row.isRequired = true
        row.selectorOptions = ["Dogwalk", "Dogsit"]
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "start_date", rowType: XLFormRowDescriptorTypeDateTime, title: "Start date")
        row.isRequired = true
        row.cellConfigAtConfigure["minimumDate"] = Date()
        row.cellConfigAtConfigure["minuteInterval"] = 10
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "end_date", rowType: XLFormRowDescriptorTypeDateTime, title: "End date")
        row.isRequired = true
        row.cellConfigAtConfigure["minimumDate"] = Date()
        row.cellConfigAtConfigure["minuteInterval"] = 10
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "location", rowType: XLFormRowDescriptorTypeSelectorPush, title: "Pickup Location")
        row.action.viewControllerClass = SelectLocationVC.self
        row.valueTransformer = LocationValueTrasformer.self
        row.isRequired = true
        section.addFormRow(row)
        
        self.form = form
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func formRowDescriptorValueHasChanged(_ formRow: XLFormRowDescriptor!, oldValue: Any!, newValue: Any!) {
        if let value = newValue as? Date, formRow.tag == "start_date" {
            let row = form.formRow(withTag: "end_date")!
            let cell: XLFormDateCell = row.cell(forForm: self) as! XLFormDateCell
            cell.minimumDate = value
            row.value = value.addingTimeInterval(3600) // add an hour
            updateFormRow(row)
        }
    }
    
    fileprivate func showCellError(_ cell: XLFormBaseCell) {
        let animation =
            CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: cell.center.x - 20.0, y: cell.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: cell.center.x + 20.0, y: cell.center.y))
        cell.layer.add(animation, forKey: "position")
    }
    
    @IBAction func saveTapped(_ sender: AnyObject) {
        let validationErrors : Array<NSError> = formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0) {
            for error in validationErrors {
                if let status = error.userInfo[XLValidationStatusErrorKey] as? XLFormValidationStatus,
                    let row: XLFormRowDescriptor = form.formRow(withTag: status.rowDescriptor!.tag!) {
                    let cell = row.cell(forForm: self)
                    showCellError(cell)
                }
            }
            return
        }
        
        let values = form.formValues()
        
        service.startDate = values["start_date"] as! Date
        service.endDate = values["end_date"] as! Date
        service.location = values["location"] as! Location
        
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
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func sendToServer() {
        SVProgressHUD.show()
        PetseeAPI.addService(service) { service, error in
            SVProgressHUD.dismiss()
            
            guard let service = service, error == nil else {
                // show error
                return
            }
            
            ServicesStore.sharedStore.add(service)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
