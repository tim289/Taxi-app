//
//  Loader.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit
import RxSwift

class Loader: NSObject {
    
    static fileprivate let tempCountCars = 30
    static fileprivate var tempCars = [CarModelSimulated]()

    func getCarsWithLocation(_ currentLocation: CLLocationCoordinate2D) -> Observable<[CarModel]> {
        return Observable<[CarModel]>.create{ observer in
            
            for car in Loader.tempCars {
                car.addCoordinate(CoordinateGenerator.getCoordinate(car.lastCoordinateFromRealCoordinates?.coordinate, currentCoordinate: currentLocation, angle: car.angle))
            }
            
            for _ in 0..<Loader.tempCountCars - Loader.tempCars.count {
                let car = CarModelSimulated(uid: UUID().uuidString,
                                            coordinate: nil,
                                            angle: Double(arc4random()).truncatingRemainder(dividingBy: 360))
                
                car.addCoordinate(CoordinateGenerator.getCoordinate(nil, currentCoordinate: currentLocation, angle: car.angle))
                Loader.tempCars.append(car)
            }
            
            for car in Loader.tempCars.enumerated().reversed() {
                if let lastCoordinate = car.element.lastCoordinateFromRealCoordinates {
                    let currentLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                    let lastLocation = CLLocation(latitude: lastCoordinate.coordinate.latitude, longitude: lastCoordinate.coordinate.longitude)
                    
                    if lastLocation.distance(from: currentLocation) > Double(CoordinateGenerator.distance) {
                        Loader.tempCars.remove(at: car.offset)
                    }
                }
            }
                        
            let dispatchTime = DispatchTime.now() + (Double(arc4random()) / Double(UINT32_MAX))
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                observer.on(.next(Loader.tempCars))
                observer.on(.completed)
            })
            
            return Disposables.create {}
        }
    }
}
