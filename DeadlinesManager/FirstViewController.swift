//
//  FirstViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 10.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func didPressSingUpButton(_ sender: UIButton) {
        guard let singInViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "SingInViewController") as? SingInViewController else {
            return
        }
        singInViewController.isRegister = true
        navigationController?.pushViewController(singInViewController, animated: true)
        
    }
    
    @IBAction func didPressSingInButton(_ sender: UIButton) {
        guard let singInViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "SingInViewController") as? SingInViewController else {
            return
        }
        singInViewController.isLogin = true
        navigationController?.pushViewController(singInViewController, animated: true)
    }
    
    

}
