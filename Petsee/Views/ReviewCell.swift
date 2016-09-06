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
    
    private var review: Review!
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
    
    private struct Static {
        static var dateFormatter: NSDateFormatter = {
            let df = NSDateFormatter()
            df.dateFormat = "LLL yyyy"
            return df
        }()
    }
    
    class func cell() -> ReviewCell {
        let nib = NSBundle.mainBundle().loadNibNamed("ReviewCell", owner: nil, options: [:])
        let cell = nib[0] as! ReviewCell
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }
    
    func configureWithReview(review: Review) {
        self.review = review
        
        if let image = review.writer?.image, url = NSURL(string: image) {
            imgUser.af_setImageWithURL(url)
        } else {
            imgUser.af_cancelImageRequest()
            imgUser.image = UIImage(named: "person-placeholder")
        }
        lblFeedback.text = review.feedback
        lblUserName.text = review.writer?.name
        lblCreatedAt.text = Static.dateFormatter.stringFromDate(review.createdAt)
        reviewStars.value = CGFloat(review.rate)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reviewStars.enabled = false
    }
}
