//
//  File.swift
//  UberAppMaor
//
//  Created by maor elimelech on 14/07/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import UIKit

extension UIView {
    func  fadtTo(alphaValue: CGFloat, withDuration duration: TimeInterval)  {
        UIView.animate(withDuration: duration) {
            self.alpha = alphaValue
        }
    }
    func bindToKeyBoard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc func keyBoardWillChange(_ notification: NSNotification)  {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let startingFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endingFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endingFrame.origin.y - startingFrame.origin.y
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
            
        }, completion: nil)
        
    }
}
