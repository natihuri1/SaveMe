//
//  UpdateService.swift
//  SaveMe
//
//  Created by nati huri on 25/07/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import UIKit

class UpdateService {
    static var instance = UpdateService()
    
    func updateUserLocation(withCoordinate coordinate: CLLocationCoordinate2D)  {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with:  { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        DataService.instance.REF_USERS.child(user.key).updateChildValues([
                            "coordinate": [coordinate.latitude,
                                           coordinate.longitude]
                            ])
                    }
                }
            }
        })
    }
 
}
