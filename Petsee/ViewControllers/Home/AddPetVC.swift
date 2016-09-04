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
            btnAddPhoto.layer.borderColor = UIColor(white: 0.5, alpha: 1).CGColor
            btnAddPhoto.layer.borderWidth = 0.5
        }
    }
    
    private var pet = Pet()
    
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
        
        var row = XLFormRowDescriptor(tag: "name", rowType: XLFormRowDescriptorTypeText, title: "Name")
        row.required = true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "birthday", rowType: XLFormRowDescriptorTypeDate, title: "Birth date")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "race", rowType: XLFormRowDescriptorTypeSelectorPush, title: "Race")
        row.action.viewControllerStoryboardId = "RaceChoose"
        row.valueTransformer = RaceFormValueTransformer.self
        row.required = true
        section.addFormRow(row)
        
        self.form = form
    }
    
    @IBAction func addPhotoTapped() {
        let imagePicker = ImagePickerController()
        imagePicker.imageLimit = 1
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        let values = form.formValues()
        pet.name = values["name"] as! String
        pet.birthday = values["birthday"] as? NSDate
        pet.race = values["race"] as! Race
        
        SVProgressHUD.show()
        PetseeAPI.addPet(pet) { pet, error in
            SVProgressHUD.dismiss()
            
            guard let pet = pet where error == nil else {
                // error
                return
            }
            
            // save pet locally
            PetsStore.sharedStore.add(pet)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddPetVC: ImagePickerDelegate {

    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismissViewControllerAnimated(true) {
            let image = images.first!
            if let imageData = UIImageJPEGRepresentation(image, 0.7) {
                PetseeAPI.uploadImage(imageData) { res, error in
                    guard let url = res?["url"] as? String else {
                        return
                    }
                    
                    self.pet.image = url
                }
            }
        }
    }
    
    func cancelButtonDidPress(imagePicker: ImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
}
