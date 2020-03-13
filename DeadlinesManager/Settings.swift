//
//  Settings.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 13.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class Settings {
   private let userDefaults = UserDefaults.standard
    
   static let shared = Settings()
   
   
   var uuID: String {
       get {
        return userDefaults.string(forKey: "uuID") ?? ""
       }
       set {
           userDefaults.set(newValue, forKey: "uuID")
       }
   }
   
}
