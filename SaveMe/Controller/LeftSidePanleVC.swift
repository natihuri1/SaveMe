//
//  LeftPanleVC.swift
//  SaveMe
//
//  Created by maor elimelech on 04/08/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import UIKit
import Firebase


class LeftSidePanelVC: UIViewController {
    let appdelegate = AppDelegate.getappDelegate()
    
    
    let userCurrentID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var loginOutBtn: UIButton!
    
    @IBOutlet weak var selfProtectModeSwitch: UISwitch!
    @IBOutlet weak var selfProtectModeLbl: UILabel!
    
    @IBOutlet weak var parkingModeSwitch: UISwitch!
    @IBOutlet weak var parkingModeLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeUsers()

        selfProtectModeSwitch.isOn = false
        selfProtectModeSwitch.isHidden = true
        //selfProtectModeLbl.isHidden = false
        
        parkingModeSwitch.isOn = false
        parkingModeSwitch.isHidden = true
        //parkingModeLbl.isHidden = false
        
        if Auth.auth().currentUser == nil {
            userEmailLbl.text = ""
           
            loginOutBtn.setTitle("Sigh UP / Login", for: .normal)
        } else {
            userEmailLbl.text = Auth.auth().currentUser?.email
           
            loginOutBtn.setTitle("LogOut", for: .normal)
        }
    }
    
    @IBAction func btnRateUs(_ sender: Any) {
        
        let appdelegate = AppDelegate()
        appdelegate.requestReview()
    }
    
    @IBAction func btnConnectUs(_ sender: Any) {
        guard  let ConnectUs = storyboard?.instantiateViewController(withIdentifier: "ConnectUsVC") else
        {return}
        presentDetails(ConnectUs)
        
    }
    
    @IBAction func btnShare(_ sender: Any) {
        
        let acticity = UIActivityViewController(activityItems: ["www.google.com"], applicationActivities: nil)
        acticity.popoverPresentationController?.sourceView = self.view
        
        self.present(acticity, animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnDonations(_ sender: Any) {
         UIApplication.shared.open(URL(string: "https://paypal.me/MONDeveloper?locale.x=he_IL")! as URL, options: [:], completionHandler: nil)
    }
    
    func observeUsers(){

        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with:  { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        self.selfProtectModeLbl.text = "התראות הגנה עצמאית"
                        self.selfProtectModeSwitch.isHidden = false
                        self.parkingModeLbl.text = "התראות על הרכב"
                        self.parkingModeSwitch.isHidden = false
                        let switchStatus = snap.childSnapshot(forPath: "protectNotification").value as! Bool
                        self.selfProtectModeSwitch.isOn = switchStatus
                        self.selfProtectModeLbl.isHidden = false

                        let parkSwitchStatus = snap.childSnapshot(forPath: "parkingNotification").value as! Bool
                        self.parkingModeSwitch.isOn = parkSwitchStatus
                        self.parkingModeLbl.isHidden = false
                    }
                }
            }
        })

    }
    
    
    @IBAction func parkingSwitchWasToggeld(_ sender: Any) {
        if parkingModeSwitch.isOn {
            parkingModeLbl.text = "כבה התראות על הרכב"
            //סוגר אוטומטית אחרי הלחיצה את המניו מניו
            //appdelegate.MenuContainerVC.toggeLeftPanel()
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["parkingNotification": true])
            
            
        }
        else {
            parkingModeLbl.text = "הפעל התראות על הרכב"
            //appdelegate.MenuContainerVC.toggeLeftPanel()
            
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["parkingNotification": false])
        }
        
        
    }
    
    
    
    
    
    
    @IBAction func protectswitchWasToggeld(_ sender: Any) {
        if selfProtectModeSwitch.isOn {
            selfProtectModeLbl.text = "כבה התראות על הגנה עצמאית"
            //סוגר אוטומטית אחרי הלחיצה את המניו מניו
            //appdelegate.MenuContainerVC.toggeLeftPanel()
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["protectNotification": true])
            
            
        }
        else {
            selfProtectModeLbl.text = "הפעל התראות על הגנה עצמאית"
            //appdelegate.MenuContainerVC.toggeLeftPanel()
            
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["protectNotification": false])
        }
    }
    
    
    @IBAction func signUPLoginBtn(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            present(loginVC!, animated: true, completion: nil)
        }
        else {
            do {
                try Auth.auth().signOut()
                userEmailLbl.text = ""
                
                selfProtectModeSwitch.isHidden = true
                selfProtectModeLbl.text = ""
                parkingModeSwitch.isHidden = true
                parkingModeLbl.text = ""
                loginOutBtn.setTitle("SighUp / Login", for: .normal)
            } catch (let error) {
                print(error)
            }
        }
        
    }
}
