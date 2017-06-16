//
//  DLog.swift
//  Petsee
//
//  Created by Ariel Pollack on 17/06/2017.
//  Copyright © 2017 Ariel Pollack. All rights reserved.
//

import Foundation

func DLog<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
    let filename = (file as NSString).lastPathComponent
    NSLog("(\(filename) \(function) #\(line)]: \(message)")
}
