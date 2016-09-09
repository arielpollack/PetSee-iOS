//
//  GoogleMapsService.swift
//  Petsee
//
//  Created by Ariel Pollack on 21/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

struct GoogleMapsService {
    
    static private let apiKey = "AIzaSyCWWlHGtPXbeu-WedlJ6TQxVAYXlzqIr7A"
    
    // add methods for loading a map from locations:
    // https://developers.google.com/maps/documentation/static-maps/intro#Paths
    
    static func imageMapForLocations(size: CGSize, locations: [Location], completion: UIImage?->()) {
        let sortedLocations = locations.sort { $0.timestamp.compare($1.timestamp) == .OrderedAscending }
        
        let scale = UIScreen.mainScreen().scale
        let scaledSize = CGSizeMake(size.width * scale, size.height * scale)
        
        let baseUrl = "https://maps.googleapis.com/maps/api/staticmap?key=\(apiKey)&size=\(Int(scaledSize.width))x\(Int(scaledSize.height))&path=color:0x0000ff|weight:5"
        var url: String = sortedLocations.reduce(baseUrl) { return $0 + "|\($1.latitude),\($1.longitude)" }
        url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        Alamofire.request(.GET, url).responseImage { response in
            completion(response.result.value)
        }
    }
    
    static func imageMapForLocation(size: CGSize, location: Location, completion: UIImage?->()) {
        let scale = UIScreen.mainScreen().scale
        let scaledSize = CGSizeMake(size.width * scale, size.height * scale)
        
        let locationString = "\(location.latitude),\(location.longitude)"
        var baseUrl = "https://maps.googleapis.com/maps/api/staticmap?key=\(apiKey)&size=\(Int(scaledSize.width))x\(Int(scaledSize.height))&center=\(locationString)&markers=color:blue|\(locationString)"
        baseUrl = baseUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        Alamofire.request(.GET, baseUrl).responseImage { response in
            completion(response.result.value)
        }
    }
}