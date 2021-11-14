//
//  PassangerAnnotation.swift
//  UberAppMaor
//
//  Created by maor elimelech on 22/07/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import Foundation
import MapKit

class ReportsAnnotation: NSObject, MKAnnotation {
    dynamic  var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, key:String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
}
