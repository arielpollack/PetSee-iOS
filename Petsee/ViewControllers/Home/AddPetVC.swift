//
//  AddPetVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import XLForm
import ImagePicker
import SVProgressHUD

class AddPetVC: XLFormViewController {

    @IBOutlet weak var btnAddPhoto: UIButton! {
        didSet {
            btnAddPhoto.layer.borderColor = UIColor(white: 0.5, alpha: 1).cgColor
            btnAddPhoto.layer.borderWidth = 0.5
            btnAddPhoto.layer.masksToBounds = true
            btnAddPhoto.imageView?.contentMode = .scaleAspectFill
        }
    }
    
    fileprivate var pet = Pet()
    
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
        
        var row = XLFormRowDescriptor(tag: "name", rowType: XLFormRowDescriptorTypeText, title: "Name")
        row.isRequired = true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "about", rowType: XLFormRowDescriptorTypeTextView, title: "About")
        row.isRequired = false
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "birthday", rowType: XLFormRowDescriptorTypeDate, title: "Birth date")
        row.isRequired = true
        row.cellConfigAtConfigure["maximumDate"] = Date()
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "race", rowType: XLFormRowDescriptorTypeSelectorPush, title: "Race")
        row.action.viewControllerStoryboardId = "RaceChoose"
        row.valueTransformer = RaceFormValueTransformer.self
        row.isRequired = true
        section.addFormRow(row)
        
        self.form = form
    }
    
    @IBAction func addPhotoTapped() {
        // image picker configuration
        var config = Configuration()
        config.recordLocation = false

        let imagePicker = ImagePickerController(configuration: config)
        imagePicker.imageLimit = 1
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
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
        pet.name = values["name"] as! String
        pet.about = values["about"] as? String
        pet.birthday = values["birthday"] as? Date
        pet.race = values["race"] as! Race
        
        SVProgressHUD.show()
        PetseeAPI.addPet(pet) { pet, error in
            SVProgressHUD.dismiss()
            
            guard let pet = pet, error == nil else {
                // error
                return
            }
            
            // save pet locally
            PetsStore.sharedStore.add(pet)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTapped() {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension AddPetVC: ImagePickerDelegate {

    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true) {
            guard let image = images.first else {
                return
            }
            
            self.btnAddPhoto.setImage(image, for: .normal)
            
            if let imageData = UIImageJPEGRepresentation(image, 0.7) {
                PetseeAPI.uploadImage(imageData) { res, error in
                    guard let res = res as? JSON, let url = res["url"] as? String else {
                        return
                    }
                    
                    self.pet.image = url
                }
            }
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
