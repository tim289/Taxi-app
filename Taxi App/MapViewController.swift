//
//  ViewController.swift
//  Taxi App
//
//  Created by Timafei Harhun on 09.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class MapViewController: UIViewController {

    fileprivate let carPointAnnotationIdentifier = "carPointAnnotationIdentifier"
    
    fileprivate var cars : Observable<[CarModel]>!
    
    @IBOutlet fileprivate weak var mapView: MKMapView!
    fileprivate let locationManager = CLLocationManager()
    
    var loadBag: DisposeBag! = DisposeBag()
    var loadObservable: Observable<Int>!
    
    var extrapolationBag: DisposeBag! = DisposeBag()
    var extrapolationObservable: Observable<Int>!

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
        
        loadObservable = Observable<Int>.interval(3.0, scheduler: MainScheduler.instance)
        
        loadObservable.subscribe(onNext: {_ in
            self.updateCars()
        }).addDisposableTo(loadBag)

        updateCars()
        
        extrapolationObservable = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
        
        extrapolationObservable.subscribe(onNext: {_ in
            self.replaceAnnotatinCars()
        }).addDisposableTo(extrapolationBag)

        replaceAnnotatinCars()
    }
    
    @objc func replaceAnnotatinCars() {
        removeCarAnnotations(with: cars, and: self.getOnlyCarPointAnnotation())
        showCarAnnotations(cars, and: self.getOnlyCarPointAnnotation())
    }
    
    @objc func updateCars() {
        if let currentLocation = locationManager.location {
            self.cars = Loader().getCarsWithLocation(currentLocation.coordinate)
        }
    }
    
    // update cars location
    func showCarAnnotations(_ cars: Observable<[CarModel]>, and annotations: [String : CarPointAnnotation]) {
        
        let disposeBag = DisposeBag()
        
        cars.asObservable().subscribe(onNext: {allCars in
            for car in allCars {
                if let annotation = annotations[car.uid] {
                    if let lastCoordinate = car.lastCoordinateWithExtrapolation {
                        annotation.carModel = car
                        annotation.coordinate = lastCoordinate.coordinate
                        if let annotationView = self.mapView.view(for: annotation) as? CarAnnotationView {
                            annotationView.setDataToInfoView()
                            
                            if let previousCoordinate = car.previousCoordinateFromAllCoordinates,
                                let lastCoordinate = car.lastCoordinateFromAllCoordinates {
                                
                                let direction = MapHelper.directionBetweenPoints(sourcePoint: MKMapPointForCoordinate(CLLocationCoordinate2DMake(lastCoordinate.coordinate.latitude, lastCoordinate.coordinate.longitude)),
                                                                                 destinationPoint: MKMapPointForCoordinate(CLLocationCoordinate2DMake(previousCoordinate.coordinate.latitude, previousCoordinate.coordinate.longitude)))
                                annotationView.rotateAnnotationView(toHeading: direction, mapView: self.mapView)
                            }
                        }
                    }
                } else {
                    let car = CarPointAnnotation(carModel: car, imageName: "taxi_ic")
                    self.mapView.addAnnotation(car)
                }
            }
        }).addDisposableTo(disposeBag)
    }
        
    func getOnlyCarPointAnnotation() -> [String : CarPointAnnotation] {
        var annotationsDictionary = [String : CarPointAnnotation]()
        for annotation in mapView.annotations {
            if let carPointAnnotation = annotation as? CarPointAnnotation {
                annotationsDictionary[carPointAnnotation.carModel.uid] = carPointAnnotation
            }
        }
        return annotationsDictionary
    }
    
    func removeCarAnnotations(with cars: Observable<[CarModel]>, and annotations: [String : CarPointAnnotation]) {
        for annotation in annotations.values {
            
            let disposeBag = DisposeBag()
            
            cars.asObservable().subscribe(onNext: {allCars in
                if !allCars.contains(annotation.carModel) {
                    self.mapView.removeAnnotation(annotation)
                }
            }).addDisposableTo(disposeBag)
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
