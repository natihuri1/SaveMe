//
//  SettingsVC.swift
//  greenColor
//
//  Created by maor elimelech on 27/06/2019.
//  Copyright © 2019 Orel Ben abu. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnRateMe(_ sender: UIButton) {
//יש עוד מטודה בdelegate
        let appdelegate = AppDelegate()
        appdelegate.requestReview()
    }
    
    @IBAction func btnShare(_ sender: Any) {
        // פותח את הקישורת שיתוף מלמטה
        let acticity = UIActivityViewController(activityItems: ["www.google.com"], applicationActivities: nil)
        acticity.popoverPresentationController?.sourceView = self.view
        
        self.present(acticity, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func btnConnectUs(_ sender: Any) {
        guard  let ConnectUs = storyboard?.instantiateViewController(withIdentifier: "ConnectUsVC") else
        {return}
        presentDetails(ConnectUs)
        
    }
    
    
    
    @IBAction func btnWebView(_ sender: Any) {
          UIApplication.shared.open(URL(string: "https://paypal.me/MONDeveloper?locale.x=he_IL")! as URL, options: [:], completionHandler: nil)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        dissmisDetails()
    }
    
    }
    


