//
//  OnboardingDataPhotoVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 09/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import ImagePicker
import SVProgressHUD

class OnboardingDataPhotoVC: OnboardingDataVC {
    
    @IBOutlet weak var imgPhoto: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    private var imageData: NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnContinue.enabled = false
    }
    
    @IBAction func photoTapped() {
        let imagePicker = ImagePickerController()
        imagePicker.imageLimit = 1
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func continueTapped() {
        self.delegate?.dataViewControllerDidEnterData(self, data: self.imageData)
    }
}


extension OnboardingDataPhotoVC: ImagePickerDelegate {
    
    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        guard let image = images.first else {
            return
        }
        
        imagePicker.dismissViewControllerAnimated(true) {
            if let imageData = UIImageJPEGRepresentation(image, 0.7) {
                self.imgPhoto.setImage(image, forState: .Normal)
                self.imageData = imageData
                self.btnContinue.enabled = true
            }
        }
    }
    
    func cancelButtonDidPress(imagePicker: ImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
}