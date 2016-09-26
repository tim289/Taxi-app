//
//  CarPointAnnotation.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit

class CarPointAnnotation: MKPointAnnotation {
    
    var carModel: CarModel
    
    fileprivate var _imageName = String()
    var imageName: String {
        return _imageName
    }
    
    
    init(carModel: CarModel, imageName: String) {
        self.carModel = carModel
        _imageName = imageName
        
        super.init()
        
        title = carModel.uid
        
        subtitle = String(describing: carModel.lastCoordinateFromRealCoordinates)
        if let lastCoordinate = carModel.lastCoordinateFromRealCoordinates {
            coordinate = lastCoordinate.coordinate
        }
    }
}
