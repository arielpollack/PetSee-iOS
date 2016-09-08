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

class CLLocationValueTrasformer : NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let valueData = value, let location = valueData as? CLLocation{
            return String(format: "%0.4f, %0.4f", location.coordinate.latitude, location.coordinate.longitude)
        }
        return nil
    }
}

class MapAnnotation : NSObject, MKAnnotation {
    
    @objc var coordinate : CLLocationCoordinate2D
    
    override init() {
        coordinate = CLLocationCoordinate2D(latitude: -33.0, longitude: -56.0)
        super.init()
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.coordinate = coordinate
    }
}

@objc(MapViewController)
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
        
        if let value = rowDescriptor?.value as? CLLocation {
            setUserLocation(value.coordinate)
        }
    }
    
    let locationManager = CLLocationManager()
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
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
        title = String(format: "%0.4f, %0.4f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude)
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if (newState == .Ending){
            if let rowDescriptor = rowDescriptor, let annotation = view.annotation {
                rowDescriptor.value = CLLocation(latitude:annotation.coordinate.latitude, longitude:annotation.coordinate.longitude)
                self.title = String(format: "%0.4f, %0.4f", annotation.coordinate.latitude, annotation.coordinate.longitude)
            }
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        setUserLocation(userLocation.coordinate)
    }
    
}

extension SelectLocationVC: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
}