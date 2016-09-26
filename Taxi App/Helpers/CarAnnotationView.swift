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
    
    fileprivate var imageView = UIImageView()
    
    fileprivate var _image: UIImage?
    override var image: UIImage? {
        set (image) {
            _image = image
            setImageView()
        }
        get {
            return _image
        }
    }
    
    fileprivate func setImageView() {
        if let image = image {
            imageView.removeFromSuperview()
            imageView = UIImageView(image: image)
            addSubview(imageView)
            imageView.center = center
        }
    }
    
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
            infoView.center = CGPoint(x: infoView.frame.size.width/18 - imageView.frame.size.width/4,
                                      y: -infoView.frame.size.height / 2.0 - imageView.frame.size.height/4)
            setDataToInfoView()
        }
    }
    
    func setDataToInfoView() {
        if let annotation = annotation as? CarPointAnnotation {
            var lastCoordinateString = ""
            if let lastCoordinate = annotation.carModel.lastCoordinateFromAllCoordinates {
                lastCoordinateString = "Latitude: \(String(lastCoordinate.coordinate.latitude))\n" + "Longitude: " + String(lastCoordinate.coordinate.longitude)
            }
            infoView.setData(annotation.carModel.uid, description: lastCoordinateString)
        }
    }
    
    
    func rotateAnnotationView(toHeading heading: Double, mapView: MKMapView) {
        // Convert mapHeading to 360 degree scale.
        var mapHeading: Double = Double(mapView.camera.heading)
        if mapHeading < 0 {
            mapHeading = fabs(mapHeading)
        } else if mapHeading > 0 {
            mapHeading = 360 - mapHeading
        }
        
        var offsetHeading: Double = (heading + mapHeading)
        while offsetHeading > 360.0 {
            offsetHeading -= 360.0
        }

        let headingInRadians: Double = offsetHeading * .pi / 180
        imageView.layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(headingInRadians)))
    }
}



