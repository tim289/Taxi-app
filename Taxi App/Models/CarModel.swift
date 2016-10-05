//
//  CarModel.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit
import RxSwift

typealias CoordinateInTime = (coordinate: CLLocationCoordinate2D, time: Date, correction: Double) // correction for extrapolation point

class CarModel: NSObject {
    
    fileprivate var _coordinatesReal = [CoordinateInTime]()
    fileprivate var _extrapolationCoordinates = [CoordinateInTime]()
    
    fileprivate var _uid = String()
    var uid: String {
        return _uid
    }
    
    init(uid: String, coordinate: CLLocationCoordinate2D?) {
        super.init()
        
        _uid = uid
        if let coordinate = coordinate {
            addCoordinate(coordinate)
        }
    }
    
    func myFrom<E>(sequence: [E]) -> Observable<E> {
        return Observable.create { observer in
            for element in sequence {
                observer.on(.next(element))
            }
            
            observer.on(.completed)
            return Disposables.create()
        }
    }
}

//MARK: Coordinate properties & functions

extension CarModel {
    
    // all codinates
    fileprivate var countCoordinates: Int? {
        return coordinates.count + _extrapolationCoordinates.count
    }
    
    fileprivate var coordinates: [CoordinateInTime] {
        return _coordinatesReal + _extrapolationCoordinates
    }
    
    var lastCoordinateFromRealCoordinates: CoordinateInTime? {
        return _coordinatesReal.last
    }
    
    var previousCoordinateFromRealCoordinates: CoordinateInTime? {
        if coordinates.count - 2 >= 0 {
            return coordinates[coordinates.count - 2]
        }
        return nil
    }
    
    var lastCoordinateFromAllCoordinates: CoordinateInTime? {
        return coordinates.last
    }
    
    var lastCoordinateWithExtrapolation: CoordinateInTime? {
        if _extrapolationCoordinates.count == 0 {
            makeExtrapolation()
            return _coordinatesReal.last
        } else {
            makeExtrapolation()
            return coordinates.last
        }
    }
    
    var previousCoordinateFromAllCoordinates: CoordinateInTime? {
        if coordinates.count - 2 >= 0 {
            return coordinates[coordinates.count - 2]
        }
        return nil
    }
    
    fileprivate var prePreviousCoordinate: CoordinateInTime? {
        if coordinates.count - 3 >= 0 {
            return coordinates[coordinates.count - 3]
        }
        return nil
    }
    
    // add non Extrapolation Coordinate
    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        _extrapolationCoordinates.removeAll()
        if _coordinatesReal.count > 2 {
            _coordinatesReal.remove(at: 0)
            addCoordinate(coordinate)
        } else {
            _coordinatesReal.append((coordinate: coordinate, time: Date(), correction: 0.0))
        }
    }
    
    // add Coordinate
    fileprivate func addExtrapolation(_ coordinate: CoordinateInTime) {
        if _extrapolationCoordinates.count > 2 {
            _extrapolationCoordinates.remove(at: 0)
            addExtrapolation(coordinate)
        } else {
            _extrapolationCoordinates.append(coordinate)
        }
    }
    
    fileprivate func makeExtrapolation() {
        if let last = coordinates.last,
            let previous = previousCoordinateFromAllCoordinates,
            let prePrevious = prePreviousCoordinate {

            addExtrapolation(Extrapolation.getNextCoordinate(withPrePrevious:prePrevious,
                                                             withPrevious: previous,
                                                             andLast: last))
            
        }
    }
}
