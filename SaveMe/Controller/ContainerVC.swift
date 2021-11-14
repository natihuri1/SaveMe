//
//  ContainerVC.swift
//  SaveMe
//
//  Created by maor elimelech on 04/08/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOfState {
    case collapsed
    case leftPanelExpened
}

enum ShowWhichVC {
    case homeVC
}

var showVC: ShowWhichVC = .homeVC

class ContainerVC: UIViewController {
    
    var homeVC: ViewController!
    var leftVC: LeftSidePanelVC!
    var centerController: UIViewController!
    var currentState: SlideOfState = .collapsed {
        didSet {
            let shouldShowShadow = (currentState != .collapsed)
            shouldShowShadowForCenterViewController(status: shouldShowShadow)
        }
    }
    
    var isHidden =  false
    let CenterPanelExpended: CGFloat = 160
    var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCenter(screen: showVC)
        
    }
    
    
    func initCenter(screen: ShowWhichVC)   {
        var presentingController: UIViewController
        
        showVC = screen
        
        if homeVC == nil {
            homeVC = UIStoryboard.homeVC()
            homeVC.delegate = self
            
            
        }
        
        presentingController = homeVC
        
        if let con = centerController {
            con.view.removeFromSuperview()
            con.removeFromParent()
        }
        centerController = presentingController
        
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
        
        
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }
}

extension ContainerVC: CenterVCDelegate {
    
    func toggeLeftPanel() {
        let notAlreadyExpended = (currentState != .leftPanelExpened)
        if notAlreadyExpended {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpended)
    }
    
    func addLeftPanelViewController() {
        if leftVC == nil {
            leftVC = UIStoryboard.leftViewController()
            addChildSidePanelViewController(leftVC!)
        }
    }
    
    
    func addChildSidePanelViewController(_ sidePanelController: LeftSidePanelVC)  {
        //view.insertSubview(sidePanelController.view, at: 0)
        view.insertSubview(sidePanelController.view, at: 0)
        addChild(sidePanelController)
        // sidePanelController.didMove(toParent: self)
        sidePanelController.didMove(toParent: self)
    }
    
    
    @objc func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand{
            isHidden = !isHidden
            
            animateStatusBar()
            setupWhiteCoverView()
            currentState = .leftPanelExpened
            
            animateCenterPanelXPositin(targetPositin: centerController.view.frame.width - CenterPanelExpended)
            
        }
        else {
            isHidden = !isHidden
            animateStatusBar()
            hideWhiteCoverView()
            
            animateCenterPanelXPositin(targetPositin: 0) { (finished) in
                if finished == true {
                    self.currentState = .collapsed
                    self.leftVC = nil
                }
            }
        }
    }
    
    
    
    func animateCenterPanelXPositin(targetPositin: CGFloat, completion: ((Bool)-> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerController.view.frame.origin.x = targetPositin
        }, completion: completion)
    }
    
    func setupWhiteCoverView()  {
        let whiteCoverView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        whiteCoverView.alpha = 0.0
        whiteCoverView.backgroundColor = UIColor.white
        whiteCoverView.tag = 20
        self.centerController.view.addSubview(whiteCoverView)
        whiteCoverView.fadtTo(alphaValue: 0.75, withDuration: 0.2)
        //        UIView.animate(withDuration: 0.3) {
        //            whiteCoverView.alpha = 0.75
        //        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(animateLeftPanel(shouldExpand:)))
        tap.numberOfTapsRequired = 1
        self.centerController.view.addGestureRecognizer(tap)
    }
    
    func hideWhiteCoverView(){
        centerController.view.removeGestureRecognizer(tap)
        for subView in self.centerController.view.subviews {
            if subView.tag == 20  {
                UIView.animate(withDuration: 0.2, animations: { subView.alpha = 0.0
                    
                }, completion: { (finished) in
                    subView.removeFromSuperview()
                })
            }
        }
        
    }
    
    func shouldShowShadowForCenterViewController(status: Bool){
        if  status == true {
            centerController.view.layer.shadowOpacity = 0.6
            
        }
        else {
            centerController.view.layer.shadowOpacity = 0.0
            
        }
    }
    
    
    
    func animateStatusBar(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations:  {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
    }
    
    
}




private extension UIStoryboard{
    class func mainStoryboard() -> UIStoryboard{
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    class func leftViewController() -> LeftSidePanelVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftSidePanelVC") as? LeftSidePanelVC
    }
    
    class func homeVC() -> ViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ViewController") as? ViewController
    }
    
    
    
}
