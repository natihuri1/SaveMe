//
//  Parking.swift
//  SaveMe
//
//  Created by nati huri on 14/07/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import Foundation

class Parking {
    
    private(set) var lat: NSNumber!
    private(set) var lon: NSNumber!
    private(set) var documentId: String!
    
    
    init(lat:NSNumber, lon:NSNumber, documentId: String)
    {
        self.lat = lat
        self.lon = lon
        self.documentId = documentId
    }
    
}

