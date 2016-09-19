//
//  Extrapolation.swift
//  Taxi App
//
//  Created by Timafei Harhun on 17.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import UIKit
import MapKit

class Extrapolation: NSObject {

    static func getNextCoordinate(withPrePrevious prePreviousCoordinateTime: CoordinateInTime,
                                  withPrevious previousCoordinateTime: CoordinateInTime,
                                  andLast lastCoordinateTime: CoordinateInTime) -> CoordinateInTime {
        
        prePreviousCoordinate = prePreviousCoordinateTime
        previousCoordinate = previousCoordinateTime
        lastCoordinate = lastCoordinateTime
        
        
        let latitude = getNextPoint(prePreviousCoordinate.coordinate.latitude,
                                    previousCoordinate: previousCoordinate.coordinate.latitude,
                                    lastCoordinate: lastCoordinate.coordinate.latitude,
                                    prePreviousTime: prePreviousCoordinate.time.timeIntervalSince1970,
                                    previousTime: previousCoordinate.time.timeIntervalSince1970,
                                    lastTime: lastCoordinate.time.timeIntervalSince1970)
        
        let longitude = getNextPoint(prePreviousCoordinate.coordinate.longitude,
                                     previousCoordinate: previousCoordinate.coordinate.longitude,
                                     lastCoordinate: lastCoordinate.coordinate.longitude,
                                     prePreviousTime: prePreviousCoordinate.time.timeIntervalSince1970,
                                     previousTime: previousCoordinate.time.timeIntervalSince1970,
                                     lastTime: lastCoordinate.time.timeIntervalSince1970)
        
        
        return (coordinate: CLLocationCoordinate2DMake(latitude, longitude), time: Date())
    }
    
}

fileprivate extension Extrapolation {
    
    static var prePreviousCoordinate = CoordinateInTime(CLLocationCoordinate2D(), Date())
    static var previousCoordinate = CoordinateInTime(CLLocationCoordinate2D(), Date())
    static var lastCoordinate = CoordinateInTime(CLLocationCoordinate2D(), Date())
    
    static func getNextPoint(_ prePreviousCoordinate: Double,
                             previousCoordinate: Double,
                             lastCoordinate: Double,
                             prePreviousTime: Double,
                             previousTime: Double,
                             lastTime: Double) -> Double {
        
        let iEstimateSpeed = getEstimateSpeed(lastCoordinate,
                                              iPreviousCoodinate: previousCoordinate,
                                              iTime: lastTime,
                                              iPreviousTime: previousTime)
        
        let iPreviousEstimateSpeed = getEstimateSpeed(previousCoordinate,
                                                      iPreviousCoodinate: prePreviousCoordinate,
                                                      iTime: previousTime,
                                                      iPreviousTime: prePreviousTime)
        
        let iEstimateAcceleration = getEstimateAcceleration(iEstimateSpeed,
                                                            iPreviousSpeed: iPreviousEstimateSpeed,
                                                            iTime: previousTime,
                                                            iPreviousTime: prePreviousTime)
        let differenceTime = Date().timeIntervalSince1970 - lastTime
        
        return lastCoordinate + iEstimateSpeed*differenceTime  + 0.5*iEstimateAcceleration*pow(differenceTime,2)
    }
    
    static func getEstimateSpeed(_ iCoodinate: CLLocationDegrees, iPreviousCoodinate: CLLocationDegrees,
                                 iTime: TimeInterval, iPreviousTime: TimeInterval) -> Double {
        return (iCoodinate - iPreviousCoodinate)/(iTime - iPreviousTime)
    }
    
    static func getEstimateAcceleration(_ iSpeed: Double, iPreviousSpeed: Double,
                                 iTime: TimeInterval, iPreviousTime: TimeInterval) -> Double {
        return (iSpeed - iPreviousSpeed)/(iTime - iPreviousTime)
    }
}
