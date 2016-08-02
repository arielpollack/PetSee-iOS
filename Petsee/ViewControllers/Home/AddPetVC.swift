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
import PetseeCore
import PetseeNetwork

class AddPetVC: XLFormViewController {

    @IBOutlet weak var btnAddPhoto: UIButton! {
        didSet {
            btnAddPhoto.layer.borderColor = UIColor(white: 0.5, alpha: 1).CGColor
            btnAddPhoto.layer.borderWidth = 0.5
        }
    }
    
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
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "birthday", rowType: XLFormRowDescriptorTypeDate, title: "Birth date")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "race", rowType: XLFormRowDescriptorTypeText, title: "Race")
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
        
    }
}

extension AddPetVC: ImagePickerDelegate {

    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        let image = images.first!
        if let imageData = UIImageJPEGRepresentation(image, 0.7) {
            PetseeAPI.uploadImage(imageData) { res, error in
                guard let url = res?["url"] as? String else {
                    return
                }
                
                print(url)
            }
        }
    }
    
    func cancelButtonDidPress(imagePicker: ImagePickerController) {
        
    }
}
