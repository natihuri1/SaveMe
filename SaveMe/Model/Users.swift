//
//  Users.swift
//  SaveMe
//
//  Created by nati huri on 14/07/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import Foundation
class Users {
   
    private(set) var documentId: String!
    private(set) var deviceId: String!

    
    private(set) var latSafeZone: NSNumber!
    private(set) var lonSafeZone: NSNumber!
    
    private(set) var latParking: NSNumber!
    private(set) var lonParking: NSNumber!
    
    private(set) var isParking: Bool!
    private(set) var isProtected: Bool!


    
    init(latSafeZone:NSNumber, lonSafeZone:NSNumber,deviceId: String,  documentId: String ,  latParking: NSNumber , lonParking: NSNumber ,isParking: Bool ,  isProtected: Bool )
    {
        self.documentId = documentId
        self.deviceId = deviceId
        self.latSafeZone = latSafeZone
        self.lonParking = lonSafeZone
        self.isParking = isParking
        self.isProtected = isProtected
    }
    
}
