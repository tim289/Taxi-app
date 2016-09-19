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

    fileprivate let carPointAnnotationIdentifier = "carPointAnnotationIdentifier"
    
    fileprivate var cars = [CarModel]()
    
    @IBOutlet fileprivate weak var mapView: MKMapView!
    fileprivate let locationManager = CLLocationManager()
    fileprivate var loadTimer = Timer()
    fileprivate var extrapolationTimer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    //MARK: Actions
    
    @IBAction fileprivate func currentLocationAction(_ sender: AnyObject) {
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
        
        loadTimer = Timer.scheduledTimer(timeInterval: 3,
                                       target: self,
                                       selector: #selector(updateCars),
                                       userInfo: nil,
                                       repeats: true)
        updateCars()
        
        extrapolationTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                  target: self,
                                                  selector: #selector(replaceAnnotatinCars),
                                                  userInfo: nil,
                                                  repeats: true)
        replaceAnnotatinCars()
    }
    
    @objc func replaceAnnotatinCars() {
        removeCarAnnotations(with: cars, and: self.getOnlyCarPointAnnotation())
        showCarAnnotations(cars, and: self.getOnlyCarPointAnnotation())
    }
    
    @objc func updateCars() {
        if let currentLocation = locationManager.location {
            Loader.getCarsWithLocation(currentLocation.coordinate, success: { (cars) in
                self.cars = cars
                self.replaceAnnotatinCars()
            })
        }
    }
    
    func showCarAnnotations(_ cars: [CarModel], and annotations: [CarPointAnnotation]) {
        for car in cars {
            let filteredArray = annotations.filter() { $0.carModel.uid == car.uid }
            if filteredArray.count > 0 {
                let annotation = filteredArray[0]
                annotation.carModel = car
                if let lastCoordinate = car.lastCoordinate {
                    annotation.coordinate = lastCoordinate.coordinate
                    if let annotationView = mapView.view(for: annotation) as? CarAnnotationView {
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
    
    func setLocation(_ location: CLLocation?) {
        if let currentLocation = location {
            let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude,
                                                longitude: currentLocation.coordinate.longitude)
            mapView.setCenterCoordinate(center, zoomLevel: 15, animated: true)
        }
    }
    
    func removeMyLocationAnnotation() {
        for annotation in mapView.annotations {
            if annotation.isKind(of: MyLocationPointAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? CarPointAnnotation {
            
            let identifier = carPointAnnotationIdentifier
            
            var annotationView = CarAnnotationView()
            if let anView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as! CarAnnotationView? {
                annotationView = anView
                annotationView.annotation = annotation
            } else {
                annotationView = CarAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            annotationView.image = UIImage(named: annotation.imageName)
            annotationView.backgroundColor = UIColor.clear
            annotationView.canShowCallout = false
            return annotationView
        }
        
        return nil
    }

}
