//
//  CoordinateGenerator.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit

class CoordinateGenerator: NSObject {
    static let distance = 10000

    static func getCoordinate(_ lastCoordinate: CLLocationCoordinate2D?, currentCoordinate: CLLocationCoordinate2D, angle: Double) -> CLLocationCoordinate2D {
        
        if let lastCoordinate = lastCoordinate {
            let distanceDriveCar = Int(arc4random()%20) + 20 // it is speed of car 20-40 metrs in 3 sec
            
            return locationForAngle(angle, fromCenterLocation: lastCoordinate, withDistance: Double(distanceDriveCar) / 111300.0)
        } else {
            
            return locationForAngle(angle, fromCenterLocation: currentCoordinate, withDistance: Double(distance) / 111300.0)
        }
    }
    
    static fileprivate func locationForAngle(_ angle: Double, fromCenterLocation center: CLLocationCoordinate2D, withDistance distance: Double) -> CLLocationCoordinate2D {
        let longitude = distance * cos(angle) + Double(center.longitude)
        let latitude = distance * sin(angle) + Double(center.latitude)

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
