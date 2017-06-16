//
//  UserProfile.swift
//  Petsee
//
//  Created by Ariel Pollack on 07/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import Alamofire
import HCSStarRatingView

class UserProfile: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var containingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMoreInfo: UILabel!
    @IBOutlet weak var lblReviewNumber: UILabel!
    @IBOutlet weak var imgUserImage: UIImageView!
    @IBOutlet weak var userImageHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reviewStars: HCSStarRatingView!
    
    let UserImageOriginalHeight: CGFloat = 160
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containingView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(containingView)
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[sv]|", options: .alignAllCenterX, metrics: nil, views: ["sv": containingView]))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sv]|", options: .alignAllCenterX, metrics: nil, views: ["sv": containingView]))
        containingView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
        
        if user == nil {
            user = AuthManager.sharedInstance.authenticatedUser!
        }
        
        setupUser()
        setupUserImage()
    }
    
    fileprivate func setupUserImage() {
        var inset = scrollView.contentInset
        inset.top += 64 + UserImageOriginalHeight
        scrollView.contentInset = inset
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: view.bounds.width, height: max(stackView.bounds.height, view.bounds.height - 64))
    }
    
    fileprivate func setupUser() {
        lblUserName.text = user.name
        lblMoreInfo.text = user.about
        lblReviewNumber.text = "Loading reviews..."
        reviewStars.value = CGFloat(user.rating ?? 0)
        reviewStars.isEnabled = false
        
        if let image = user.image, let url = URL(string: image) {
            imgUserImage.af_setImage(withURL: url)
        } else {
            imgUserImage.image = UIImage(named: "user-placeholder")
        }
        
        loadReviews()
    }
    
    fileprivate func loadReviews() {
        activityIndicator.startAnimating()
        PetseeAPI.userReviews(user.id) { (reviews, error) in
            self.activityIndicator.stopAnimating()
            
            guard let reviews = reviews, reviews.count > 0 else {
                self.lblReviewNumber.text = "No Reviews Yet..."
                return
            }
            
            self.lblReviewNumber.text = "\(reviews.count) Reviews"
            
            // show only first 10 reviews
            for review in reviews[0..<min(10, reviews.count)] {
                let reviewCell = ReviewCell.cell()
                reviewCell.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200)
                reviewCell.configureWithReview(review)
                self.stackView.addArrangedSubview(reviewCell)
            }
            
            self.scrollView.layoutIfNeeded()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topOffset = max(-scrollView.contentOffset.y, 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(topOffset, 0, 0, 0)
        userImageHeight.constant = topOffset
    }
}
