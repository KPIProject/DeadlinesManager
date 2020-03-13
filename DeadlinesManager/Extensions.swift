//
//  Extensions.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 10.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

extension UIView {
    
    class var identifier: String {
        return String(describing: self)
    }
    
}
extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
