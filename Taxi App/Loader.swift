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
    
    static fileprivate let tempCountCars = 30
    static fileprivate var tempCars = [CarModel]()

    static func getCarsWithLocation(_ currentLocation: CLLocationCoordinate2D,
                                    success: ([CarModel]) -> Void) {
        
        for car in tempCars {
            car.addCoordinate(CoordinateGenerator.getCoordinate(car.lastCoordinate, currentCoordinate: currentLocation, angle: car.angle))
        }
        
        for _ in 0..<tempCountCars - tempCars.count {
            tempCars.append(CarModel(uid: UUID().uuidString,
                coordinate: CoordinateGenerator.getCoordinate(nil, currentCoordinate: currentLocation, angle: CarModel().angle)))
        }
        
        for car in tempCars {
            if let lastCoordinate = car.lastCoordinate {
                let currentLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                let lastLocation = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)

                print("Distance \(car.uid) \(lastLocation.distance(from: currentLocation))")
                if lastLocation.distance(from: currentLocation) > Double(CoordinateGenerator.distance) {
                    tempCars.remove(at: tempCars.index(of: car)!)
                }
            }
        }
        
        success(tempCars)
    }
}
