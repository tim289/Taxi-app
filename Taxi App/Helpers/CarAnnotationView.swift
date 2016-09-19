//
//  CarAnnotationView.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit

class CarAnnotationView: MKAnnotationView {
    
    fileprivate var _infoView: InfoCarAnnotationView?
    
    var infoView: InfoCarAnnotationView {
        get {
            if _infoView == nil {
                _infoView = (Bundle.main.loadNibNamed("InfoCarAnnotationView", owner: nil, options: nil)?[0] as? InfoCarAnnotationView)!
                return _infoView!
            } else {
                return _infoView!
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.superview?.bringSubview(toFront: self)
        
        if (!selected) {
            infoView.removeFromSuperview()
        } else {
            addSubview(infoView)
            infoView.center = CGPoint(x: infoView.frame.size.width/18, y: -infoView.frame.size.height / 2.0)
            setDataToInfoView()
        }
    }
    
    func setDataToInfoView() {
        if let annotation = annotation as? CarPointAnnotation {
            var lastCoordinateString = ""
            if let lastCoordinate = annotation.carModel.lastCoordinate {
                lastCoordinateString = "Latitude: \(String(lastCoordinate.coordinate.latitude))\n" + "Longitude: " + String(lastCoordinate.coordinate.longitude)
            }
            infoView.setData(annotation.carModel.uid, description: lastCoordinateString)
        }
    }
}
