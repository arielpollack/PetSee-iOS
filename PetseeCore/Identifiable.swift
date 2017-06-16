//
//  Identifiable.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

protocol Identifiable: Equatable {
    var id: Int! { get set }
}
func ==<T>(lhs: T, rhs: T) -> Bool where T: Identifiable {
    return lhs.id == rhs.id
}
