//
//  MapHelper.swift
//  Taxi App
//
//  Created by Timafei Harhun on 23.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import UIKit
import MapKit

class MapHelper: NSObject {

    static func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    static func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    static func directionBetweenPoints(sourcePoint: MKMapPoint, destinationPoint : MKMapPoint) -> CLLocationDirection {
        let x : Double = destinationPoint.x - sourcePoint.x
        let y : Double = destinationPoint.y - sourcePoint.y
        
        return fmod(radiansToDegrees(radians: atan2(y, x)), 360.0)
    }
        
}
