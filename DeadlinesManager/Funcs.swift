//
//  Funcs.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 19.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

open class Funcs {
    
    public func noticeAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okBtn)
        return alert
    }

}

