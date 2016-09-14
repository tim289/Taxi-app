//
//  MKMapView.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    var zoomLevel: Int! {
        get {
            return Int(log2(360 * ((self.frame.size.width/256) / CGFloat(self.region.span.longitudeDelta))) + 1)
        }
    }
    
    func setCenterCoordinate(_ centerCoordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
        let span = MKCoordinateSpanMake(0, 360/pow(2, Double(zoomLevel)) * Double(self.frame.size.width/256))
        self.setRegion(MKCoordinateRegionMake(centerCoordinate, span), animated: animated)
    }
    
    func setZoomLevel (_ zoomLevel: Int) {
        setCenterCoordinate(self.centerCoordinate, zoomLevel: zoomLevel, animated: false)
    }
}
