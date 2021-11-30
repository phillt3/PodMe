//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Phillip  Tracy on 11/10/21.
//

import UIKit

extension UIBarButtonItem{
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
