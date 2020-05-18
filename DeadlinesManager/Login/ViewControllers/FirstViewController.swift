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
        signUpBetton.layer.cornerRadius = CGFloat((Double(signUpBetton.frame.height) ) / 3.5)
        singInButton.layer.cornerRadius = CGFloat((Double(singInButton.frame.height) ) / 3.5)
        signUpBetton.layer.borderWidth = 2.0
        singInButton.layer.borderWidth = 2.0
        signUpBetton.layer.borderColor = #colorLiteral(red: 0.0536134094, green: 0.1874043941, blue: 0.2290870845, alpha: 1)
        singInButton.layer.borderColor = #colorLiteral(red: 0.0536134094, green: 0.1874043941, blue: 0.2290870845, alpha: 1)
        
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
