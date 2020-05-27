//
//  Int+Extensions.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 27.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit


extension Int {
    
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return formatter.string(from: date)
    }
    
}
