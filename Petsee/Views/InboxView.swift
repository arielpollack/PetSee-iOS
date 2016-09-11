//
//  InboxView.swift
//  Petsee
//
//  Created by Ariel Pollack on 11/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class InboxView: UIView {

    private lazy var imgInbox: UIButton = {
        let iv = UIButton(type: .Custom)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.setImage(UIImage(named: "inbox"), forState: .Normal)
        return iv
    }()
    
    private lazy var lblCount: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFontOfSize(12)
        lbl.textColor = UIColor.whiteColor()
        lbl.textAlignment = .Center
        lbl.backgroundColor = UIColor.redColor()
        lbl.hidden = true
        lbl.layer.cornerRadius = 10
        lbl.layer.masksToBounds = true
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViews()
    }

    private func loadViews() {
        addSubview(imgInbox)
        addSubview(lblCount)
        
        imgInbox.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        imgInbox.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        imgInbox.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        imgInbox.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        
        lblCount.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: 5).active = true
        lblCount.topAnchor.constraintEqualToAnchor(topAnchor, constant: -5).active = true
        lblCount.heightAnchor.constraintEqualToConstant(20).active = true
        lblCount.widthAnchor.constraintEqualToConstant(20).active = true
    }
    
    func setAction(target: AnyObject, action: Selector) {
        imgInbox.addTarget(target, action: action, forControlEvents: .TouchUpInside)
    }
    
    func setBadgeCount(count: Int) {
        if count == 0 {
            lblCount.hidden = true
        } else {
            lblCount.text = "\(count)"
            lblCount.hidden = false
        }
    }
}
