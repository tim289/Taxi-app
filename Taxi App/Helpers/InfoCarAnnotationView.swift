//
//  InfoCarAnnotationView.swift
//  Taxi App
//
//  Created by Timafei Harhun on 12.09.16.
//  Copyright © 2016 TsimafeiHarhun. All rights reserved.
//

import Foundation
import MapKit

class InfoCarAnnotationView: UIView {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setData(_ title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }

}
