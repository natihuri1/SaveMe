//
//  Reports.swift
//  SaveMe
//
//  Created by nati huri on 14/07/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import Foundation

class Reports {
    
    private(set) var type: Bool!
    private(set) var lat: NSNumber!
    private(set) var lon: NSNumber!
    private(set) var created : Date!
    private(set) var documentId: String!


    init(type: Bool, lat:NSNumber, lon:NSNumber, documentId: String, created : Date) {
        self.type = type
        self.lat = lat
        self.lon = lon
        self.created = created
    }

}
