//
//  CenterVCDelegate.swift
//  SaveMe
//
//  Created by maor elimelech on 04/08/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//

import Foundation


protocol CenterVCDelegate {
    func toggeLeftPanel()
    func addLeftPanelViewController()
    func animateLeftPanel(shouldExpand: Bool)
}
