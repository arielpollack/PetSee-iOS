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
    
    static fileprivate let apiKey = "AIzaSyCWWlHGtPXbeu-WedlJ6TQxVAYXlzqIr7A"
    
    // add methods for loading a map from locations:
    // https://developers.google.com/maps/documentation/static-maps/intro#Paths
    
    static func imageMapForLocations(_ size: CGSize, locations: [Location], completion: @escaping (UIImage?)->()) {
        let sortedLocations = locations.sorted { $0.timestamp.compare($1.timestamp as Date) == .orderedAscending }
        
        let scale = UIScreen.main.scale
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let baseUrl = "https://maps.googleapis.com/maps/api/staticmap?key=\(apiKey)&size=\(Int(scaledSize.width))x\(Int(scaledSize.height))&path=color:0x0000ff|weight:5"
        var url: String = sortedLocations.reduce(baseUrl) { return $0 + "|\($1.latitude),\($1.longitude)" }
        url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        DLog("loading google map url: \(url)")
        
        Alamofire.request(url).responseImage { response in
            completion(response.result.value)
        }
    }
    
    static func imageMapForLocation(_ size: CGSize, location: Location, completion: @escaping (UIImage?)->()) {
        let scale = UIScreen.main.scale
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let locationString = "\(location.latitude),\(location.longitude)"
        var baseUrl = "https://maps.googleapis.com/maps/api/staticmap?key=\(apiKey)&size=\(Int(scaledSize.width))x\(Int(scaledSize.height))&center=\(locationString)&markers=color:blue|\(locationString)"
        baseUrl = baseUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        DLog("loading google map url: \(baseUrl)")
        
        Alamofire.request(baseUrl).responseImage { response in
            completion(response.result.value)
        }
    }
    
    static func addressForLocation(_ location: Location, completion: @escaping (String?)->()) {
        
        let locationString = "\(location.latitude),\(location.longitude)"
        var baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?key=\(apiKey)&latlng=\(locationString)&result_type=street_address"
        baseUrl = baseUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        Alamofire.request(baseUrl).responseJSON { response in
            if let json = response.result.value as? JSON,
                let results = json["results"] as? [JSON],
                let result = results.first,
                let address = result["formatted_address"] as? String {
                completion(address)
            } else {
                completion(nil)
            }
        }
    }
}
