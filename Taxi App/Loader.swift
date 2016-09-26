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
    
    static fileprivate let tempCountCars = 1
    static fileprivate var tempCars = [CarModelSimulated]()

    static func getCarsWithLocation(_ currentLocation: CLLocationCoordinate2D,
                                    success: ([CarModel]) -> Void) {
        
        for car in tempCars {
            car.addCoordinate(CoordinateGenerator.getCoordinate(car.lastCoordinateFromRealCoordinates?.coordinate, currentCoordinate: currentLocation, angle: car.angle))
        }
        
        for _ in 0..<tempCountCars - tempCars.count {
            let car = CarModelSimulated(uid: UUID().uuidString,
                                        coordinate: nil,
                                        angle: Double(arc4random()).truncatingRemainder(dividingBy: 360))
            
            car.addCoordinate(CoordinateGenerator.getCoordinate(nil, currentCoordinate: currentLocation, angle: car.angle))
            tempCars.append(car)
        }
        
        for car in tempCars.enumerated().reversed() {
            if let lastCoordinate = car.element.lastCoordinateFromRealCoordinates {
                let currentLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                let lastLocation = CLLocation(latitude: lastCoordinate.coordinate.latitude, longitude: lastCoordinate.coordinate.longitude)

                if lastLocation.distance(from: currentLocation) > Double(CoordinateGenerator.distance) {
                    tempCars.remove(at: car.offset)
                }
            }
        }
        
        success(tempCars)
    }
}
