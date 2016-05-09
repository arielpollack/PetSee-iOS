//
//  ReviewCell.swift
//  Petsee
//
//  Created by Ariel Pollack on 08/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import PetseeCore

class ReviewCell: UIView {
    
    private var review: Review!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblFeedback: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    
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
        
        imgUser.image = UIImage(named: "dummy-profile")
        lblFeedback.text = review.feedback
        lblUserName.text = review.writer?.name
        lblCreatedAt.text = Static.dateFormatter.stringFromDate(review.createdAt)
        lblRate.text = "\(review.rate)"
    }
}
