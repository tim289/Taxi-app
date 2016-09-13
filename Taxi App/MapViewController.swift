//
//  ViewController.swift
//  Taxi App
//
//  Created by Timafei Harhun on 09.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    private let carPointAnnotationIdentifier = "carPointAnnotationIdentifier"
    
    @IBOutlet private weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    //MARK: Actions
    
    @IBAction private func currentLocationAction(sender: AnyObject) {
        setLocation(locationManager.location)
    }

}

//MARK: - Private Methods

private extension MapViewController {
    func setupData() {
        
        mapView.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        setLocation(locationManager.location)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                           target: self,
                                                           selector: #selector(updateCars),
                                                           userInfo: nil,
                                                           repeats: true)
        updateCars()
    }
    
    @objc func updateCars() {
        if let currentLocation = locationManager.location {
            Loader.getCarsWithLocation(currentLocation.coordinate, success: { (cars) in
                self.removeCarAnnotations(with: cars, and: self.getOnlyCarPointAnnotation())
                self.showCarAnnotations(cars, and: self.getOnlyCarPointAnnotation())
            })
        }
    }
    
    func showCarAnnotations(cars: [CarModel], and annotations: [CarPointAnnotation]) {
        for car in cars {
            let filteredArray = annotations.filter() { $0.carModel.uid == car.uid }
            if filteredArray.count > 0 {
                let annotation = filteredArray[0]
                annotation.carModel = car
                if let lastCoordinate = car.lastCoordinate {
                    annotation.coordinate = lastCoordinate
                    if let annotationView = mapView.viewForAnnotation(annotation) as? CarAnnotationView {
                        annotationView.setDataToInfoView()
                    }
                }
            } else {
                let car = CarPointAnnotation(carModel: car, imageName: "taxi_ic")
                mapView.addAnnotation(car)
            }
        }
    }
    
    func getOnlyCarPointAnnotation() -> [CarPointAnnotation] {
        if let annotations = mapView.annotations.filter( { (annotation: MKAnnotation) -> Bool in
            if ((annotation as? CarPointAnnotation) != nil) {
                return true
            } else {
                return false
            }
        }) as? [CarPointAnnotation] {
            return annotations
        }
        return [CarPointAnnotation]()
    }
    
    func removeCarAnnotations(with cars: [CarModel], and annotations: [CarPointAnnotation]) {
        for annotation in annotations {
            let filteredArray = cars.filter() { $0.uid == annotation.carModel.uid }
            if filteredArray.count == 0 {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    //MARK: Location
    
    func setLocation(location: CLLocation?) {
        if let currentLocation = location {
            let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude,
                                                longitude: currentLocation.coordinate.longitude)
            mapView.setCenterCoordinate(center, zoomLevel: 15, animated: true)
        }
    }
    
    func removeMyLocationAnnotation() {
        for annotation in mapView.annotations {
            if annotation.isKindOfClass(MyLocationPointAnnotation) {
                mapView.removeAnnotation(annotation)
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let point = MyLocationPointAnnotation()
            point.coordinate = location.coordinate
            point.title = "I'm here!"
            
            removeMyLocationAnnotation()
            mapView.addAnnotation(point)
        }
       
    }
}

//MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? CarPointAnnotation {
            
            let identifier = carPointAnnotationIdentifier
            
            var annotationView = CarAnnotationView()
            if let anView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! CarAnnotationView? {
                annotationView = anView
                annotationView.annotation = annotation
            } else {
                annotationView = CarAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            annotationView.image = UIImage(named: annotation.imageName)
            annotationView.backgroundColor = UIColor.clearColor()
            annotationView.canShowCallout = false
            return annotationView
        }
        
        return nil
    }

}