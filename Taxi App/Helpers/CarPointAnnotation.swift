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

    var carModel = CarModel()
    
    private var _imageName = String()
    var imageName: String {
        return _imageName
    }
    
    override init() {
        super.init()
    }
    
    init(carModel: CarModel, imageName: String) {
        super.init()
        self.carModel = carModel
        _imageName = imageName
        title = carModel.uid
        
        subtitle = String(carModel.lastCoordinate)
        if let lastCoordinate = carModel.lastCoordinate{
            coordinate = lastCoordinate
        }
    }
}
