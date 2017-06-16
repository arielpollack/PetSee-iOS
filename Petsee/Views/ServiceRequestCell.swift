//
//  ServiceRequestCell.swift
//  Petsee
//
//  Created by Ariel Pollack on 08/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import HCSStarRatingView
import AlamofireImage

protocol ServiceRequestCellDelegate: NSObjectProtocol {
    func didApproveServiceRequest(_ request: ServiceRequest)
    func didDenyServiceRequest(_ request: ServiceRequest)
}

class ServiceRequestCell: UITableViewCell {
    
    @IBOutlet weak var imgClientThumb: UIImageView! {
        didSet {
            imgClientThumb.layer.cornerRadius = imgClientThumb.bounds.height / 2
            imgClientThumb.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var lblClientName: UILabel!
    @IBOutlet weak var lblClientReviewCount: UILabel!
    @IBOutlet weak var reviewStars: HCSStarRatingView! {
        didSet {
            reviewStars.isEnabled = false
        }
    }
    @IBOutlet weak var slidingViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var imgDeny: UIImageView!
    @IBOutlet weak var imgApprove: UIImageView!
    
    var serviceRequest: ServiceRequest! {
        didSet {
            loadServiceRequest()
        }
    }
    weak var delegate: ServiceRequestCellDelegate?
    
    fileprivate func loadServiceRequest() {
        let client = serviceRequest.service!.client
        if let image = client?.image, let url = URL(string: image) {
            imgClientThumb.af_setImage(withURL: url)
        }
        
        lblClientName.text = client?.name
        lblClientReviewCount.text = "(\(client?.ratingCount ?? 0) reviews)"
        reviewStars.value = CGFloat(client?.rating ?? 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgClientThumb.af_cancelImageRequest()
        imgClientThumb.image = UIImage(named: "user_profile_icon")
        slidingViewTrailing.constant = 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        contentView.addGestureRecognizer(gesture)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    fileprivate var startPanLocation: CGPoint?
    func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            startPanLocation = sender.location(in: contentView)
            
        case .changed:
            let location = sender.location(in: contentView)
            let diff = location.x - startPanLocation!.x
            slidingViewTrailing.constant = -diff * (1 - abs(diff) / contentView.bounds.width / 3)
            if diff > 0 {
                imgApprove.isHidden = false
                imgDeny.isHidden = true
                actionView.backgroundColor = UIColor(hex: "#27ae60")
            } else {
                imgApprove.isHidden = true
                imgDeny.isHidden = false
                actionView.backgroundColor = UIColor(hex: "#c0392b")
            }
            
        case .ended:
            let location = sender.location(in: contentView)
            let diff = location.x - startPanLocation!.x
            var approve = true
            var changed = true
            if diff > contentView.bounds.width / 2 {
                slidingViewTrailing.constant = -contentView.bounds.width
            } else if diff < -contentView.bounds.width / 2 {
                approve = false
                slidingViewTrailing.constant = contentView.bounds.width
            } else {
                changed = false
                slidingViewTrailing.constant = 0
            }
            UIView.animate(withDuration: 0.2, animations: { 
                self.contentView.layoutIfNeeded()
            }, completion: { finished in
                if finished && changed {
                    if approve {
                        self.delegate?.didApproveServiceRequest(self.serviceRequest)
                    } else {
                        self.delegate?.didDenyServiceRequest(self.serviceRequest)
                    }
                }
            })
            
        default: break
        }
    }
}
