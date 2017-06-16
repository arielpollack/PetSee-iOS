//
//  ReviewCell.swift
//  Petsee
//
//  Created by Ariel Pollack on 08/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import HCSStarRatingView

class ReviewCell: UIView {
    
    fileprivate var review: Review!
    @IBOutlet weak var imgUser: UIImageView! {
        didSet {
            imgUser.layer.cornerRadius = imgUser.bounds.height / 2
            imgUser.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var lblFeedback: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!
    @IBOutlet weak var reviewStars: HCSStarRatingView!
    
    fileprivate struct Static {
        static var dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "LLL yyyy"
            return df
        }()
    }
    
    class func cell() -> ReviewCell {
        let nib = Bundle.main.loadNibNamed("ReviewCell", owner: nil, options: [:])
        let cell = nib?[0] as! ReviewCell
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }
    
    func configureWithReview(_ review: Review) {
        self.review = review
        
        if let image = review.writer?.image, let url = URL(string: image) {
            imgUser.af_setImage(withURL: url)
        } else {
            imgUser.af_cancelImageRequest()
            imgUser.image = UIImage(named: "person-placeholder")
        }
        lblFeedback.text = review.feedback
        lblUserName.text = review.writer?.name
        lblCreatedAt.text = Static.dateFormatter.string(from: review.createdAt as Date)
        reviewStars.value = CGFloat(review.rate)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reviewStars.isEnabled = false
    }
}
