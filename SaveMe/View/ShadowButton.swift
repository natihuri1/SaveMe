//
//  ShadowButton.swift
//  UberAppMaor
//
//  Created by maor elimelech on 12/07/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import UIKit

class ShadowButton: UIButton {
    var originalSize: CGRect?
    
    override func awakeFromNib() {
        setUpView()
    }

    func setUpView()  {
        originalSize = self.frame
        self.layer.cornerRadius = 5.0
        self.layer.shadowRadius = 10.0
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize.zero
    }
    func  animatedButton(shuldLoad: Bool, withMessege messege: String)  {
        let spinner = UIActivityIndicatorView()
        spinner.style = .whiteLarge
        spinner.color = UIColor.darkGray
        spinner.alpha = 0.0
        spinner.hidesWhenStopped = true
        spinner.tag = 21

        
        if shuldLoad {
            self.addSubview(spinner)
            self.setTitle("", for: .normal)
            UIView.animate(withDuration: 0.2, animations: {
            self.layer.cornerRadius = self.frame.height / 2
                self.frame = CGRect(x: self.frame.midX - (self.frame.height / 2), y: self.frame.origin.y, width: self.frame.height, height: self.frame.height)
            }, completion: { (finished) in
                if finished == true {
                    spinner.startAnimating()
                    spinner.center = CGPoint(x: self.frame.width / 2, y: self.frame.width / 2 + 1)
                    spinner.fadtTo(alphaValue: 1.0, withDuration: 0.2)
                    
                    
                   // UIView.animate(withDuration: 0.2, animations: {
                        //spinner.alpha = 0.1
                        
                   // })
                }
            })
            // אם המשתמש לחץ על הכפתור שיחזור למצב הרגיל
            self.isUserInteractionEnabled = false
        
        } else{
            
            self.isUserInteractionEnabled = true
            for subView in self.subviews{
                if subView.tag == 21   {
                subView.removeFromSuperview()
            }
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.layer.cornerRadius = 0.5
                self.frame = self.originalSize!
                self.setTitle(messege, for: .normal)
                
            })
        }
    }

}
