//
//  DataService.swift
//  SaveMe
//
//  Created by nati huri on 25/07/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import Firebase
import MapKit
import UIKit



let DB_BASE = Database.database().reference()


class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_REPORTS = DB_BASE.child("reports")
//    private var _REF_TRIPS = DB_BASE.child("trips")
    
    var REF_BASE: DatabaseReference{
        return _REF_BASE
    }
    var REF_USERS:  DatabaseReference{
        return _REF_USERS
    }
    var REF_REPORTS:  DatabaseReference{
        return _REF_REPORTS
    }

    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, Any>)  {
            REF_USERS.child(uid).updateChildValues(userData)
    }
    func createReportsDB(uid: String,reportsData: Dictionary<String, Any>){
        DataService.instance.REF_REPORTS.updateChildValues(reportsData)
    }
    
 
}
