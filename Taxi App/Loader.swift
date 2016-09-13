//
//  Loader.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit

class Loader: NSObject {
    
    static private let tempCountCars = 30
    static private var tempCars = [CarModel]()

    static func getCarsWithLocation(currentLocation: CLLocationCoordinate2D,
                                    success: ([CarModel]) -> Void) {
        
        for car in tempCars {
            car.addCoordinate(CoordinateGenerator.getCoordinate(car.lastCoordinate, currentCoordinate: currentLocation, angle: car.angle))
        }
        
        for _ in 0..<tempCountCars - tempCars.count {
            tempCars.append(CarModel(uid: NSUUID().UUIDString,
                coordinate: CoordinateGenerator.getCoordinate(nil, currentCoordinate: currentLocation, angle: CarModel().angle)))
        }
        
        for car in tempCars {
            if let lastCoordinate = car.lastCoordinate {
                let currentLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                let lastLocation = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)

                print("Distance \(car.uid) \(lastLocation.distanceFromLocation(currentLocation))")
                if lastLocation.distanceFromLocation(currentLocation) > Double(CoordinateGenerator.distance) {
                    tempCars.removeAtIndex(tempCars.indexOf(car)!)
                }
            }
        }
        
        success(tempCars)
    }
}
