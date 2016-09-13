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
    
    private var _infoView: InfoCarAnnotationView?
    
    var infoView: InfoCarAnnotationView {
        get {
            if _infoView == nil {
                _infoView = (NSBundle.mainBundle().loadNibNamed("InfoCarAnnotationView", owner: nil, options: nil)[0] as? InfoCarAnnotationView)!
                return _infoView!
            } else {
                return _infoView!
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        self.superview?.bringSubviewToFront(self)
        
        if (!selected) {
            infoView.removeFromSuperview()
        } else {
            addSubview(infoView)
            infoView.center = CGPointMake(infoView.frame.size.width/18, -infoView.frame.size.height / 2.0)
            setDataToInfoView()
        }
    }
    
    func setDataToInfoView() {
        if let annotation = annotation as? CarPointAnnotation {
            var lastCoordinateString = ""
            if let lastCoordinate = annotation.carModel.lastCoordinate {
                lastCoordinateString = "Latitude: \(String(lastCoordinate.latitude))\n" + "Longitude: " + String(lastCoordinate.longitude)
            }
            infoView.setData(annotation.carModel.uid, description: lastCoordinateString)
        }
    }
}
