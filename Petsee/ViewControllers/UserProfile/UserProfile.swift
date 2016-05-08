//
//  UserProfile.swift
//  Petsee
//
//  Created by Ariel Pollack on 07/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import Alamofire
import PetseeCore
import PetseeNetwork

class UserProfile: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var containingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMoreInfo: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblReviewNumber: UILabel!
    @IBOutlet weak var imgUserImage: UIImageView!
    @IBOutlet weak var userImageHeight: NSLayoutConstraint!
    
    let UserImageOriginalHeight: CGFloat = 160
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containingView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(containingView)
        scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[sv]|", options: .AlignAllCenterX, metrics: nil, views: ["sv": containingView]))
        scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sv]|", options: .AlignAllCenterX, metrics: nil, views: ["sv": containingView]))
        containingView.widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor, multiplier: 1).active = true
        
        setupUser()
        setupUserImage()
    }
    
    private func setupUserImage() {
        var inset = scrollView.contentInset
        inset.top += 64 + UserImageOriginalHeight
        scrollView.contentInset = inset
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSizeMake(view.bounds.width, max(stackView.bounds.height, view.bounds.height - 64))
    }
    
    private func setupUser() {
        lblUserName.text = user.name
        lblAbout.text = user.about
        lblReviewNumber.text = "Loading reviews..."
        imgUserImage.image = UIImage(named: "dummy-profile")
        
        PetseeAPI.userReviews(user.id) { (reviews, error) in
            guard let reviews = reviews where reviews.count > 0 else {
                self.lblReviewNumber.text = "No Reviews Yet..."
                return
            }
            
            self.lblReviewNumber.text = "\(reviews.count) Reviews"
            
            // show only first 3 reviews
            var views = [UIView]()
            for review in reviews[0...2] {
                let reviewLabel = UILabel()
                reviewLabel.numberOfLines = 0
                reviewLabel.font = UIFont.italicSystemFontOfSize(15)
                reviewLabel.text = review.feedback
                reviewLabel.hidden = true
                views.append(reviewLabel)
                self.stackView.addArrangedSubview(reviewLabel)
            }
            UIView.animateWithDuration(0.2, animations: {
                views.forEach({  $0.hidden = false })
            }, completion: { finished in
                if finished {
                    self.scrollView.layoutIfNeeded()
                }
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let topOffset = max(-scrollView.contentOffset.y, 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(topOffset, 0, 0, 0)
        userImageHeight.constant = topOffset
    }
}