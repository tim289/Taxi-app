//
//  CarModel.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit

class CarModel: NSObject {
    
    private var _angle = Double()
    var angle: Double {
        return _angle
    }
    
    private var _uid = String()
    var uid: String {
        return _uid
    }
    
    private var _coordinate = [CLLocationCoordinate2D]()
    var lastCoordinate: CLLocationCoordinate2D? {
        return _coordinate.last
    }
    
    override init() {
        super.init()
        _angle = Double(arc4random())%360
    }
    
    convenience init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.init()
        
        _uid = uid
        addCoordinate(coordinate)
    }
    
    func addCoordinate(coordinate: CLLocationCoordinate2D) {
        if _coordinate.count > 2 {
            _coordinate.removeAtIndex(0)
            addCoordinate(coordinate)
        } else {
            _coordinate.append(coordinate)
        }
    }
}