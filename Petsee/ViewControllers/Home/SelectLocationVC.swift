//
//  SelectLocationVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 08/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import MapKit
import XLForm
import SVProgressHUD

class LocationValueTrasformer : NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let valueData = value, let location = valueData as? Location {
            return location.address ?? String(format: "%0.4f, %0.4f", location.latitude, location.longitude)
        }
        return nil
    }
}

class MapAnnotation : NSObject, MKAnnotation {
    
    dynamic var coordinate : CLLocationCoordinate2D
    
    override init() {
        coordinate = CLLocationCoordinate2D(latitude: -33.0, longitude: -56.0)
        super.init()
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.coordinate = coordinate
    }
}

@objc(SelectLocationVC)
class SelectLocationVC : UIViewController, XLFormRowDescriptorViewController, MKMapViewDelegate {
    
    var rowDescriptor: XLFormRowDescriptor?
    lazy var mapView : MKMapView = { [unowned self] in
        let mapView = MKMapView(frame: self.view.frame)
        mapView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        return mapView
    }()
    
    var annotation: MapAnnotation?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(mapView)
        mapView.delegate = self
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleGesture))
        pinchGesture.delegate = self
        mapView.addGestureRecognizer(pinchGesture)
        
        if let value = rowDescriptor?.value as? Location {
            setUserLocation(CLLocationCoordinate2D(latitude: value.latitude, longitude: value.longitude))
        }
    }
    
    let locationManager = CLLocationManager()
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    private func setUserLocation(value: CLLocationCoordinate2D) {
        guard annotation == nil else {
            return
        }
        
        annotation = MapAnnotation(coordinate: value)
        mapView.addAnnotation(annotation!)
        var region = MKCoordinateRegionMakeWithDistance(value, 500, 500)
        region = mapView.regionThatFits(region)
        mapView.region = region
        mapView.setCenterCoordinate(value, animated: false)
        didChooseLocation(value)
    }
    
    private func didChooseLocation(coordinate: CLLocationCoordinate2D) {
        let location = Location()
        
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        
        SVProgressHUD.show()
        GoogleMapsService.addressForLocation(location) { [weak self] address in
            SVProgressHUD.dismiss()
            location.address = address
            self?.rowDescriptor?.value = location
            self?.title = address ?? String(format: "%0.4f, %0.4f", coordinate.latitude, coordinate.longitude)
        }
    }
    
    //MARK - - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MapAnnotation.self) {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            pinAnnotationView.pinTintColor =  MKPinAnnotationView.redPinColor()
            pinAnnotationView.draggable = true
            pinAnnotationView.animatesDrop = true
            return pinAnnotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        setUserLocation(userLocation.coordinate)
    }
    
    // MARK: handle gestures
    
    func handleGesture(gesture: UIGestureRecognizer) {
        annotation?.coordinate = mapView.centerCoordinate
        
        if [.Ended, .Cancelled].contains(gesture.state) {
            didChooseLocation(mapView.centerCoordinate)
        }
    }
}

extension SelectLocationVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SelectLocationVC: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
}