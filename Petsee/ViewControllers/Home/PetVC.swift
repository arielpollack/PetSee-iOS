//
//  PetVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 19/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import AlamofireImage

class PetVC: UIViewController {
    
    @IBOutlet weak var lblPetName: UILabel!
    @IBOutlet weak var imgPetThumbnail: UIImageView!
    
    var pet: Pet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPetName.text = pet.name

        if let imageString = pet.image, imageURL = NSURL(string: imageString) {
            imgPetThumbnail.af_setImageWithURL(imageURL)
        }
    }
    
    @IBAction func exitTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}