//
//  LocationManager.swift
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
    
    private var trackingServices: [Service]!
    lazy private var locationManager: CLLocationManager = {
        let m = CLLocationManager()
        m.delegate = self
        m.desiredAccuracy = kCLLocationAccuracyBest
        m.distanceFilter = 20
        return m
    }()
    private var permissionRequestCompletion: ((Bool)->())?
    
    private override init() {
        super.init()
        
        trackingServices = UserDefaultsManager.lastTrackedServices
        startLocationTrackingIfNeeded()
    }
    
    func startLocationUpdates() {
        // dummy func to get things running
    }
    
    private func hasLocationPermissions() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            return true
            
        default:
            return false
        }
    }
    
    private func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    private func startLocationTrackingIfNeeded() {
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
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func stopLocationTrackingIfNeeded() {
        guard trackingServices.count == 0 else {
            return
        }
        
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    private func updateLocationForService(service: Service, location: CLLocation) {
        let coordinate = location.coordinate
        // we don't care about the callback
        PetseeAPI.addLocationForService(coordinate.latitude, longitude: coordinate.longitude, service: service, completion: { location, error in
            print(location, error)
        })
    }
    
    func startTrackingService(service: Service) {
        guard !trackingServices.contains(service) else {
            return
        }
        
        trackingServices.append(service)
        UserDefaultsManager.lastTrackedServices = trackingServices
        startLocationTrackingIfNeeded()
    }
    
    func stopTrackingService(service: Service) {
        guard trackingServices.contains(service) else {
            return
        }
        
        trackingServices.removeAtIndex(trackingServices.indexOf(service)!)
        UserDefaultsManager.lastTrackedServices = trackingServices
        stopLocationTrackingIfNeeded()
    }
}

extension LocationHandler: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // callback with success only if we have the right permission
        permissionRequestCompletion?(status == .AuthorizedAlways)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // make sure the location is recent (past 15 seconds)
        guard let location = locations.last where abs(location.timestamp.timeIntervalSinceNow) < 15 else {
            return
        }
        
        for service in trackingServices {
            updateLocationForService(service, location: location)
        }
    }
}