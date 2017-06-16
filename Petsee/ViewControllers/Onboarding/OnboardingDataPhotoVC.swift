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
    
    fileprivate var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnContinue.isEnabled = false
    }
    
    @IBAction func photoTapped() {
        // image picker configuration
        var config = Configuration()
        config.recordLocation = false

        let imagePicker = ImagePickerController(configuration: config)
        imagePicker.imageLimit = 1
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func continueTapped() {
        self.delegate?.dataViewControllerDidEnterData(self, data: self.imageData)
    }
}


extension OnboardingDataPhotoVC: ImagePickerDelegate {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard let image = images.first else {
            return
        }
        
        imagePicker.dismiss(animated: true) {
            if let imageData = UIImageJPEGRepresentation(image, 0.7) {
                self.imgPhoto.setImage(image, for: .normal)
                self.imageData = imageData
                self.btnContinue.isEnabled = true
            }
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
