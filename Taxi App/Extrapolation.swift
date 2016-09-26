//
//  Extrapolation.swift
//  Taxi App
//
//  Created by Timafei Harhun on 17.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import UIKit
import MapKit

//Source: https://habrahabr.ru/company/2gis/blog/308500/

class Extrapolation: NSObject {

    fileprivate static let acceptableError = 0.000001
    
    fileprivate static var prePreviousCoordinate = CoordinateInTime(CLLocationCoordinate2D(), Date(), 0.0)
    fileprivate static var previousCoordinate = CoordinateInTime(CLLocationCoordinate2D(), Date(), 0.0)
    fileprivate static var lastCoordinate = CoordinateInTime(CLLocationCoordinate2D(), Date(), 0.0)
    
    static func getNextCoordinate(withPrePrevious prePreviousCoordinateTime: CoordinateInTime,
                                  withPrevious previousCoordinateTime: CoordinateInTime,
                                  andLast lastCoordinateTime: CoordinateInTime) -> CoordinateInTime {
        
        prePreviousCoordinate = prePreviousCoordinateTime
        previousCoordinate = previousCoordinateTime
        lastCoordinate = lastCoordinateTime
        
        let currentTime = Date().timeIntervalSince1970
        
        //Next point(latitude&longitude)
        let latitude = getNextPoint(prePreviousCoordinate.coordinate.latitude,
                                    previousCoordinate: previousCoordinate.coordinate.latitude,
                                    lastCoordinate: lastCoordinate.coordinate.latitude,
                                    prePreviousTime: prePreviousCoordinate.time.timeIntervalSince1970,
                                    previousTime: previousCoordinate.time.timeIntervalSince1970,
                                    lastTime: lastCoordinate.time.timeIntervalSince1970,
                                    currentTime: currentTime)
        
        let longitude = getNextPoint(prePreviousCoordinate.coordinate.longitude,
                                     previousCoordinate: previousCoordinate.coordinate.longitude,
                                     lastCoordinate: lastCoordinate.coordinate.longitude,
                                     prePreviousTime: prePreviousCoordinate.time.timeIntervalSince1970,
                                     previousTime: previousCoordinate.time.timeIntervalSince1970,
                                     lastTime: lastCoordinate.time.timeIntervalSince1970,
                                     currentTime: currentTime)
    
//        let correction = getCorrection(currentTime,
//                                       lastCorrection: lastCoordinate.correction,
//                                       previousTime: previousCoordinate.time.timeIntervalSince1970,
//                                       lastTime:  lastCoordinate.time.timeIntervalSince1970)
//        print(correction)
//
        return (coordinate: CLLocationCoordinate2DMake(latitude , longitude),
                time: Date(),
                correction: 0.0)
    }
    
}

//MARK: Get Next point

fileprivate extension Extrapolation {
    
    // Next point of the car without error S(i)[t] = S(i) + V(i)*(t - t(i-1)) + 0.5*Alpha(i)*(t - t(i-1))*(t - t(i-1))
    static func getNextPoint(_ prePreviousCoordinate: Double,
                             previousCoordinate: Double,
                             lastCoordinate: Double,
                             prePreviousTime: Double,
                             previousTime: Double,
                             lastTime: Double,
                             currentTime: Double) -> Double {
        
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
                                                            iTime: lastTime,
                                                            iPreviousTime: previousTime)
        
        let differenceTime = currentTime - lastTime
        let newCoordinate = lastCoordinate + iEstimateSpeed*differenceTime  + 0.5*iEstimateAcceleration*pow(differenceTime,2)
        
        return newCoordinate
    }
    
    // Speed of the car V(i) ≈ (S(i) - S(i-1))/(t(i) - t(i-1))
    static func getEstimateSpeed(_ iCoodinate: CLLocationDegrees,
                                 iPreviousCoodinate: CLLocationDegrees,
                                 iTime: TimeInterval,
                                 iPreviousTime: TimeInterval) -> Double {
        return (iCoodinate - iPreviousCoodinate)/(iTime - iPreviousTime)
    }
    
    // Acceleration of the car Alpha(i) = (V(i) - V(i-1))/(t(i) - t(i-1))
    static func getEstimateAcceleration(_ iSpeed: Double,
                                        iPreviousSpeed: Double,
                                        iTime: TimeInterval,
                                        iPreviousTime: TimeInterval) -> Double {
        return (iSpeed - iPreviousSpeed)/(iTime - iPreviousTime)
    }
}

//MARK: Get error point

fileprivate extension Extrapolation {
    static func getCorrection(_ currentDate: Double,
                              lastCorrection: Double,
                              previousTime: Double,
                              lastTime: Double) -> Double {
        let t = lastTime - previousTime
        
        let thirdConstant = getThirdConstant(acceptableError: acceptableError,
                                             timeCorrection: t,
                                             lastCorrection: lastCorrection)
        
        let secondConstant = getSecondConstant(acceptableError: acceptableError,
                                               timeCorrection: t,
                                               lastCorrection: lastCorrection)
        let differenceTime = currentDate - lastTime

        return thirdConstant*pow(differenceTime, 3) + secondConstant*pow(differenceTime, 2) +
                acceptableError*differenceTime + lastCorrection
    }
   
    
    static func getThirdConstant(acceptableError: Double,
                                 timeCorrection: Double,
                                 lastCorrection: Double) -> Double {
        return (acceptableError*timeCorrection + 2*lastCorrection)/pow(timeCorrection, 3)
    }
    
    static func getSecondConstant(acceptableError: Double,
                                 timeCorrection: Double,
                                 lastCorrection: Double) -> Double {
        return (-1)*(2*acceptableError*timeCorrection + 2*lastCorrection)/pow(timeCorrection, 3)
    }
    
}


