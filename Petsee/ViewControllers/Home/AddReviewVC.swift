//
//  AddReviewVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 10/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SVProgressHUD

class AddReviewVC: UIViewController {
    
    @IBOutlet weak var reviewStars: HCSStarRatingView!
    @IBOutlet weak var txtFeedback: UITextView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    
    private var review = Review()
    var user: User! {
        didSet {
            review.user = user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPlaceholder.text = "What can you say about \(user.name!)"
        title = user.name
        
        preloadReview()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        txtFeedback.becomeFirstResponder()
    }
    
    private func preloadReview() {
        SVProgressHUD.show()
        PetseeAPI.myReviewOnUser(user) { review, error in
            SVProgressHUD.dismiss()
            
            guard let review = review where error == nil else {
                return
            }
            
            self.review = review
            self.reviewStars.value = CGFloat(review.rate)
            self.txtFeedback.text = review.feedback
            
            self.lblPlaceholder.hidden = review.feedback != nil
        }
    }
    
    private func commitFilledReview() {
        review.feedback = txtFeedback.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        review.rate = Int(reviewStars.value)
    }
    
    @IBAction func submitTapped() {
        commitFilledReview()
        
        if review.rate < 1 {
            return
        }
        
        PetseeAPI.createReview(review) { _, error in
            guard error == nil else {
                // show error
                return
            }
            
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}

extension AddReviewVC: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        lblPlaceholder.hidden = true
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        lblPlaceholder.hidden = textView.text.characters.count > 0
        return true
    }
}

