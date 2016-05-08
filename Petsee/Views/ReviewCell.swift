//
//  ReviewCell.swift
//  Petsee
//
//  Created by Ariel Pollack on 08/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import PetseeCore

class ReviewCell: UITableViewCell {
    
    private var review: Review!
    
    func configureWithReview(review: Review) {
        self.review = review
    }
}
