//
//  ServiceProviderCell.swift
//  Petsee
//
//  Created by Ariel Pollack on 05/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import HCSStarRatingView

protocol ServiceProviderCellDelegate: NSObjectProtocol {
    func sendRequestForServiceProvider(provider: ServiceProvider)
    func chooseServiceRequest(request: ServiceRequest)
}

class ServiceProviderCell: UITableViewCell {
    
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblReviewsCount: UILabel!
    @IBOutlet weak var ratingStars: HCSStarRatingView! {
        didSet {
            ratingStars.minimumValue = 0
            ratingStars.enabled = false
        }
    }
    @IBOutlet weak var btnSendRequest: UIButton!
    
    var serviceProvider: ServiceProvider! {
        didSet {
            loadServiceProviderInfo()
        }
    }
    var serviceRequest: ServiceRequest? {
        didSet {
            loadServiceRequestInfo()
        }
    }
    
    weak var delegate: ServiceProviderCellDelegate?
    
    private func loadServiceProviderInfo() {
        lblName.text = serviceProvider.name
        ratingStars.value = CGFloat(serviceProvider.rating ?? 0)
        lblReviewsCount.text = "(\(serviceProvider.ratingCount ?? 0) reviews)"
        if let image = serviceProvider.image, url = NSURL(string: image) {
            imgThumbnail.af_setImageWithURL(url)
        } else {
            imgThumbnail.af_cancelImageRequest()
            imgThumbnail.image = nil
        }
    }
    
    private func loadServiceRequestInfo() {
        if let request = serviceRequest {
            if request.status == .Approved {
                btnSendRequest.setTitle("Choose", forState: .Normal)
                btnSendRequest.enabled = true
            } else {
                btnSendRequest.setTitle(request.status.readableString, forState: .Normal)
                btnSendRequest.enabled = false
            }
        } else {
            btnSendRequest.setTitle("Send Request", forState: .Normal)
            btnSendRequest.enabled = true
        }
    }
    
    @IBAction func sendRequestTapped() {
        if let request = serviceRequest where request.status == .Approved {
            delegate?.chooseServiceRequest(request)
        } else {
            delegate?.sendRequestForServiceProvider(serviceProvider)
        }
    }
}
