//
//  Identifiable.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation

typealias JSON = [String: AnyObject]

protocol Identifiable: Equatable {
    var id: Int! { get set }
}
func ==<T where T: Identifiable>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}