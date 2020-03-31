//
//  ViewManager.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 13.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class ViewManager {
    static let shared = ViewManager()
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    private let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    private let loginStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
    
    func setupInitialController() {
        if let window = self.appDelegate?.window {
            let loginVC = loginStoryboard.instantiateInitialViewController()
            let mainVC = mainStoryboard.instantiateInitialViewController()
            print(Settings.shared.uuID)
            if Settings.shared.uuID == "" {
                window.rootViewController = loginVC
            } else {
                window.rootViewController = mainVC
            }
//            window.rootViewController = Settings.shared.uuID != "" ? mainVC : loginVC
            window.makeKeyAndVisible()
            //window.rootViewController = mainVC
            
        }
    }
    
    func toMainVC() {
        if let window = self.appDelegate?.window {
            let mainVC = mainStoryboard.instantiateInitialViewController()
            window.rootViewController =  mainVC
        }
    }
    
    func toLoginVC() {
        if let window = self.appDelegate?.window {
            let loginVC = loginStoryboard.instantiateInitialViewController()
            window.rootViewController =  loginVC
        }
    }

}
