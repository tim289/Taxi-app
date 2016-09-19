//
//  CarModel.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit

typealias CoordinateInTime = (coordinate: CLLocationCoordinate2D, time: Date)

class CarModel: NSObject {
    
    fileprivate var _coordinate = [CoordinateInTime]()
    fileprivate var _extrapolationCoordinate = [CoordinateInTime]()

    fileprivate var _angle = Double()
    var angle: Double {
        return _angle
    }
    
    fileprivate var _uid = String()
    var uid: String {
        return _uid
    }
    
    override init() {
        super.init()
        _angle = Double(arc4random()).truncatingRemainder(dividingBy: 360)
    }
    
    convenience init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.init()
        
        _uid = uid
        addCoordinate(coordinate)
    }
}

//MARK: Coordinate

extension CarModel {
    
    fileprivate var countCoordinates: Int? {
        return _coordinate.count + _extrapolationCoordinate.count
    }
    
    fileprivate var coordinates: [CoordinateInTime] {
        return _coordinate + _extrapolationCoordinate
    }
    
    var lastCoordinate: (coordinate: CLLocationCoordinate2D, time: Date)? {
        if _extrapolationCoordinate.count == 0 {
            makeExtrapolation()
            return _coordinate.last
        } else {
            makeExtrapolation()
            return coordinates.last
        }
    }
    
    fileprivate var previousCoordinate: (coordinate: CLLocationCoordinate2D, time: Date)? {
        if coordinates.count - 2 >= 0 {
            return coordinates[coordinates.count - 2]
        }
        return nil
    }
    fileprivate var prePreviousCoordinate: (coordinate: CLLocationCoordinate2D, time: Date)? {
        if coordinates.count - 3 >= 0 {
            return coordinates[coordinates.count - 3]
        }
        return nil
    }
    
    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        _extrapolationCoordinate.removeAll()
        if _coordinate.count > 2 {
            _coordinate.remove(at: 0)
            addCoordinate(coordinate)
        } else {
            _coordinate.append((coordinate: coordinate, time: Date()))
        }
    }
    
    func makeExtrapolation() {
        if let last = coordinates.last,
            let previous = previousCoordinate,
            let prePrevious = prePreviousCoordinate {
            _extrapolationCoordinate.append(Extrapolation.getNextCoordinate(withPrePrevious:prePrevious,
                                                                            withPrevious: previous,
                                                                            andLast: last))
            let locLast = CLLocation(latitude: last.coordinate.latitude, longitude:last.coordinate.longitude)
            let locLastD = CLLocation(latitude: _extrapolationCoordinate.last!.coordinate.latitude, longitude:_extrapolationCoordinate.last!.coordinate.longitude)
            
        }
    }
}
