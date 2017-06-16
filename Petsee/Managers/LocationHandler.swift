//
//  LocationHandler.swift
//  Petsee
//
//  Created by Ariel Pollack on 09/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHandler: NSObject {
    
    static var sharedManager: LocationHandler {
        struct Static {
            static let manager = LocationHandler()
        }
        return Static.manager
    }
    
    fileprivate var trackingServices: [Service]!
    lazy fileprivate var locationManager: CLLocationManager = {
        let m = CLLocationManager()
        m.delegate = self
        m.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        m.distanceFilter = 20
        return m
    }()
    fileprivate var permissionRequestCompletion: ((Bool)->())?
    
    fileprivate override init() {
        super.init()
        
        trackingServices = UserDefaultsManager.lastTrackedServices
        startLocationTrackingIfNeeded()
    }
    
    func startLocationUpdates() {
        // dummy func to get things running
    }
    
    fileprivate func hasLocationPermissions() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return true
            
        default:
            return false
        }
    }
    
    fileprivate func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    fileprivate func startLocationTrackingIfNeeded() {
        guard trackingServices.count > 0 else {
            return
        }
        
        // make sure we have permissions
        if !hasLocationPermissions() {
            
            // request permission
            permissionRequestCompletion = { success in
                self.permissionRequestCompletion = nil
                if success {
                    self.startLocationTrackingIfNeeded()
                }
            }
            requestLocationPermission()
            return
        }
        
        print("starting location tracking")
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    fileprivate func stopLocationTrackingIfNeeded() {
        guard trackingServices.count == 0 else {
            return
        }
        
        print("stopping location tracking")
        
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    fileprivate func updateLocationForService(_ service: Service, location: CLLocation) {
        let coordinate = location.coordinate
        // we don't care about the callback
        PetseeAPI.addLocationForService(coordinate.latitude, longitude: coordinate.longitude, service: service, completion: { location, error in
            print("updated location for service \(service.id)")
        })
    }
    
    func startTrackingService(_ service: Service) {
        guard !trackingServices.contains(service) else {
            return
        }
        
        print("started tracking service \(service.id)")
        
        trackingServices.append(service)
        UserDefaultsManager.lastTrackedServices = trackingServices
        startLocationTrackingIfNeeded()
    }
    
    func stopTrackingService(_ service: Service) {
        guard trackingServices.contains(service) else {
            return
        }
        
        print("stopped tracking service \(service.id)")
        
        trackingServices.remove(at: trackingServices.index(of: service)!)
        UserDefaultsManager.lastTrackedServices = trackingServices
        stopLocationTrackingIfNeeded()
    }
}

extension LocationHandler: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // callback with success only if we have the right permission
        permissionRequestCompletion?(status == .authorizedAlways)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // make sure the location is recent (past 15 seconds)
        guard let location = locations.last, abs(location.timestamp.timeIntervalSinceNow) < 15 else {
            return
        }
        
        for service in trackingServices {
            updateLocationForService(service, location: location)
        }
    }
}
