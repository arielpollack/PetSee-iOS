//
//  InboxView.swift
//  Petsee
//
//  Created by Ariel Pollack on 11/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class InboxView: UIView {

    fileprivate lazy var imgInbox: UIButton = {
        let iv = UIButton(type: .custom)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.setImage(UIImage(named: "inbox"), for: UIControlState())
        return iv
    }()
    
    fileprivate lazy var lblCount: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.backgroundColor = UIColor.red
        lbl.isHidden = true
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

    fileprivate func loadViews() {
        addSubview(imgInbox)
        addSubview(lblCount)
        
        imgInbox.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imgInbox.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imgInbox.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imgInbox.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        lblCount.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 5).isActive = true
        lblCount.topAnchor.constraint(equalTo: topAnchor, constant: -5).isActive = true
        lblCount.heightAnchor.constraint(equalToConstant: 20).isActive = true
        lblCount.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setAction(_ target: AnyObject, action: Selector) {
        imgInbox.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setBadgeCount(_ count: Int) {
        if count == 0 {
            lblCount.isHidden = true
        } else {
            lblCount.text = "\(count)"
            lblCount.isHidden = false
        }
    }
}
