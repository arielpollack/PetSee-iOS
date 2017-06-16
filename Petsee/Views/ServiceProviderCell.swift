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
    func sendRequestForServiceProvider(_ provider: ServiceProvider)
    func chooseServiceRequest(_ request: ServiceRequest)
}

class ServiceProviderCell: UITableViewCell {
    
    @IBOutlet weak var imgThumbnail: UIImageView! {
        didSet {
            imgThumbnail.layer.cornerRadius = imgThumbnail.bounds.height / 2
            imgThumbnail.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblReviewsCount: UILabel!
    @IBOutlet weak var ratingStars: HCSStarRatingView! {
        didSet {
            ratingStars.minimumValue = 0
            ratingStars.isEnabled = false
        }
    }
    @IBOutlet weak var btnSendRequest: UIButton!
    @IBOutlet weak var lblHourlyRate: UILabel!
    
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
    
    static let rateFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        return nf
    }()
    
    weak var delegate: ServiceProviderCellDelegate?
    
    fileprivate func loadServiceProviderInfo() {
        lblName.text = serviceProvider.name
        ratingStars.value = CGFloat(serviceProvider.rating ?? 0)
        lblReviewsCount.text = "(\(serviceProvider.ratingCount ?? 0) reviews)"
        lblHourlyRate.text = ServiceProviderCell.rateFormatter.string(from: NSNumber(value: serviceProvider.hourlyRate as Int))
        if let image = serviceProvider.image, let url = URL(string: image) {
            imgThumbnail.af_setImage(withURL: url)
        }
    }
    
    fileprivate func loadServiceRequestInfo() {
        if let request = serviceRequest {
            if request.status == .Approved {
                btnSendRequest.setTitle("Choose", for: UIControlState())
                btnSendRequest.isEnabled = true
            } else {
                btnSendRequest.setTitle(request.status.readableString, for: UIControlState())
                btnSendRequest.isEnabled = false
            }
        } else {
            btnSendRequest.setTitle("Send Request", for: UIControlState())
            btnSendRequest.isEnabled = true
        }
    }
    
    @IBAction func sendRequestTapped() {
        if let request = serviceRequest, request.status == .Approved {
            delegate?.chooseServiceRequest(request)
        } else {
            delegate?.sendRequestForServiceProvider(serviceProvider)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgThumbnail.image = UIImage(named: "person-placeholder")
        imgThumbnail.af_cancelImageRequest()
    }
}
