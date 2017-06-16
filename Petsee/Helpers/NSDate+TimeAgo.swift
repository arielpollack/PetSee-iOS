//
//  NSDate+TimeAgo.swift
//  Petsee
//
//  Created by Ariel Pollack on 12/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation

extension Date {
    
    var timeAgo: String {
        let deltaSeconds = secondsFrom(self)
        let deltaMinutes:Double = Double(deltaSeconds / 60)
        
        if (deltaSeconds < 5) {
            return "Just now"
        }
        if (deltaSeconds < 60) {
            return String(deltaSeconds) + " seconds ago"
        }
        if (deltaSeconds < 120) {
            return "A minute ago"
        }
        if (deltaMinutes < 60) {
            return String(Int(deltaMinutes)) + " minutes ago"
        }
        if (deltaMinutes < 120) {
            return "An hour ago"
        }
        if (deltaMinutes < (24 * 60)) {
            let hours = flooredString(deltaMinutes, dividedBy: 60)
            return hours + " hours ago"
        }
        if (deltaMinutes < (24 * 60 * 2)) {
            return "Yesterday";
        }
        if (deltaMinutes < (24 * 60 * 7)) {
            let days = flooredString(deltaMinutes, dividedBy: (60 * 24))
            return days + " days ago"
        }
        if (deltaMinutes < (24 * 60 * 14)) {
            return "Last week";
        }
        if (deltaMinutes < (24 * 60 * 31)) {
            let weeks = flooredString(deltaMinutes, dividedBy: (60 * 24 * 7))
            return weeks + " weeks ago"
        }
        if (deltaMinutes < (24 * 60 * 61)) {
            return "Last month";
        }
        if (deltaMinutes < (24 * 60 * 365.25)) {
            let months = flooredString(deltaMinutes, dividedBy: (60 * 24 * 30))
            return months + " months ago"
        }
        if (deltaMinutes < (24 * 60 * 731)) {
            return "Last year";
        }
        
        let years = flooredString(deltaMinutes, dividedBy: (60 * 24 * 365))
        return years + " years ago"
    }
    
    fileprivate func secondsFrom(_ date:Date) -> Int {
        return (Calendar.current as NSCalendar).components(.second, from: date, to: Date(), options: []).second!
    }
    
    fileprivate func flooredString(_ delta: Double, dividedBy: Double) -> String {
        return String(Int(floor(delta/dividedBy)))
    }
}
