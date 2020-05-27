//
//  Settings.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 13.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

/**
 Singleton class settings.
 Store all information about user in `UserDefaults`
 
 Can store:
    - uuID: user unique identifier
    - firstName: user first name
    - secondName: user second name
    - login: userName
    - creatingTime: user creation time
 */
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
    
    var firstName: String {
        get {
            return userDefaults.string(forKey: "firstName") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "firstName")
        }
    }
    
    var secondName: String {
        get {
            return userDefaults.string(forKey: "secondName") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "secondName")
        }
    }
    
    var login: String {
        get {
            return userDefaults.string(forKey: "login") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "login")
        }
    }
    
    var creatingTime: Int {
        get {
            return userDefaults.integer(forKey: "creatingTime")
        }
        set {
            userDefaults.set(newValue, forKey: "creatingTime")
        }
    }
   
}
