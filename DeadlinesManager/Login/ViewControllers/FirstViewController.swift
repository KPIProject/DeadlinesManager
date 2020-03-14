//
//  FirstViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 10.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    @IBOutlet weak var signUpBetton: UIButton!
    @IBOutlet weak var singInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpBetton.layer.cornerRadius = CGFloat((Double(signUpBetton.frame.height) ) / 2.5)
        singInButton.layer.cornerRadius = CGFloat((Double(singInButton.frame.height) ) / 2.5)
        
    }
    
    
    @IBAction func didPressSingUpButton(_ sender: UIButton) {
        guard let singInViewController = UIStoryboard(name: "Login", bundle: .main).instantiateViewController(withIdentifier: "SingInViewController") as? SingInViewController else {
            return
        }
        singInViewController.isRegister = true
        navigationController?.pushViewController(singInViewController, animated: true)
        
    }
    
    @IBAction func didPressSingInButton(_ sender: UIButton) {
        guard let singInViewController = UIStoryboard(name: "Login", bundle: .main).instantiateViewController(withIdentifier: "SingInViewController") as? SingInViewController else {
            return
        }
        singInViewController.isLogin = true
        navigationController?.pushViewController(singInViewController, animated: true)
    }
    
    

}
