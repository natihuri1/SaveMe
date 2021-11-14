//
//  EXControllerMove.swift
//  greenColor
//
//  Created by maor elimelech on 27/06/2019.
//  Copyright © 2019 Orel Ben abu. All rights reserved.
//

import UIKit


// מעבר בין העמודים כמו של מניו
extension UIViewController{
    func presentDetails(_ viewControllerToPresent: UIViewController)  {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window?.layer.add(transition, forKey:"transition")
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    func dissmisDetails(){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey:"transition")
        dismiss(animated: false, completion: nil)
    }
    
}
