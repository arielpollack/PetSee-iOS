//
//  ServiceCell.swift
//  Petsee
//
//  Created by Ariel Pollack on 20/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import AlamofireImage

class ServiceCell: UITableViewCell {
    
    @IBOutlet weak var imgPetThumbnail: UIImageView! {
        didSet {
            imgPetThumbnail.layer.cornerRadius = imgPetThumbnail.bounds.height / 2
            imgPetThumbnail.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var lblPetName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblType: UILabel!
    
    static let dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "dd LLL, HH:mm"
        return df
    }()
    
    var service: Service! {
        didSet {
            loadServiceInfo()
        }
    }
    
    private func loadServiceInfo() {
        lblPetName.text = service.pet.name
        lblStatus.text = service.status.readableString
        lblStatus.textColor = service.status.presentingColor
        lblType.text = service.type.readableString
        lblDate.text = ServiceCell.dateFormatter.stringFromDate(service.startDate)
        
        if let imageString = service.pet.image, imageURL = NSURL(string: imageString) {
            imgPetThumbnail.af_setImageWithURL(imageURL)
        } else {
            imgPetThumbnail.image = nil
            imgPetThumbnail.af_cancelImageRequest()
        }
    }
}