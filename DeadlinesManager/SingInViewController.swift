//
//  ViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 05.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class SingInViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    
    var isLogin = false
    var isRegister = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isLogin{
            nameLabel.isHidden = true
            confirmPasswordLabel.isHidden = true
            nameTextField.isHidden = true
            confirmPasswordTextField.isHidden = true
            let newConstraint = stackViewHeightConstraint.constraintWithMultiplier(0.2)
            view.removeConstraint(stackViewHeightConstraint)
            view.addConstraint(newConstraint)
            view.layoutIfNeeded()
            stackViewHeightConstraint = newConstraint
        }
        
        if isRegister{
            nameLabel.isHidden = false
            confirmPasswordLabel.isHighlighted = false
            nameTextField.isHidden = false
            confirmPasswordTextField.isHidden = false
        }
        
    }

    @IBAction func didPressSignInButton(_ sender: UIButton) {
        if isLogin{
            
        }
        
        if isRegister{
            //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid

            let parameters = ["user_first_name": "13", "user_second_name": "jack", "username" : "11111", "password" : "12345"] as [String : Any]

            //create the url with URL
            let url = URL(string: "http://192.168.31.88:8080/main/registration")! //change the url

            //create the session object
            let session = URLSession.shared

            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "POST" //set http method as POST

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            } catch let error {
                print(error.localizedDescription)
            }

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

                guard error == nil else {
                    return
                }

                guard let data = data else {
                    return
                }

                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        print(json)
                        // handle json...
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        }
    }
    
}

