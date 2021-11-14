//
//  ConnectUsVC.swift
//  greenColor
//
//  Created by maor elimelech on 27/06/2019.
//  Copyright © 2019 Orel Ben abu. All rights reserved.
//
import Firebase
import UIKit
import FirebaseFirestore


class ConnectUsVC: UIViewController {
    

    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var txtUser: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSend.bindToKeyBoard()
    }
    
    @IBAction func btnCancle(_ sender: Any) {
        dissmisDetails()
    }
    
    
    @IBAction func btnSend(_ sender: Any) {
       
        
        if txtUser.text!.isEmpty
        {
            alertForEmpty()
           dissmisDetails()
        }
        else  {
            print("imHere")
        saveContactUser()
        alertForUpload()
        print("save Connect")
            dissmisDetails()
        }
        
    }
    
   fileprivate func saveContactUser()  {
    let  db = Firestore.firestore()
    
            var ref: DocumentReference? = nil
            ref = db.collection(CONNECT_US_REF).addDocument(data: [
                USER_NAME : userName.text!,
                TXT_FIELD: txtUser.text!,
    
                ])
            { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
                //DONT FORGET!! Loop = deviceId
            }
            self.clearFields()
    
    
    }
    
    func alertForUpload()
    {
        let alert = UIAlertController(title: "הודעתך נשלחה בהצלחה", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
       
        
    }
    
    func alertForEmpty()
    {
        let alert = UIAlertController(title: "אין אפשרות לשלוח הודעה ריקה", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    func  clearFields(){
        userName.text = ""
        txtUser.text  = ""
        print("fields clean")
    }
}
