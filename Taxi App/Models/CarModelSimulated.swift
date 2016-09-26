//
//  CarModelSimulated.swift
//  Taxi App
//
//  Created by Timafei Harhun on 22.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import UIKit
import MapKit

class CarModelSimulated: CarModel {

    fileprivate var _angle = Double()
    var angle: Double {
        return _angle
    }
    
    init(uid: String, coordinate: CLLocationCoordinate2D?, angle: Double) {
        super.init(uid: uid, coordinate: coordinate)
        
        _angle = angle
    }
}
