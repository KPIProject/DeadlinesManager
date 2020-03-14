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
    @IBOutlet weak var secondNameLabel: UILabel!
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    
    var isLogin = false
    var isRegister = false

    override func viewDidLoad() {
        super.viewDidLoad()
        /// User pressed Login
        if isLogin {
            nameLabel.isHidden = true
            secondNameLabel.isHidden = true
            confirmPasswordLabel.isHidden = true
            nameTextField.isHidden = true
            secondNameTextField.isHidden = true
            confirmPasswordTextField.isHidden = true
            confirmButton.setTitle("Увійти", for: .normal)
            
            
            let newConstraint = stackViewHeightConstraint.constraintWithMultiplier(0.2)
            view.removeConstraint(stackViewHeightConstraint)
            view.addConstraint(newConstraint)
            view.layoutIfNeeded()
            stackViewHeightConstraint = newConstraint
        }
        /// User pressed Register
        if isRegister {
            nameLabel.isHidden = false
            secondNameLabel.isHidden = false
            confirmPasswordLabel.isHighlighted = false
            nameTextField.isHidden = false
            secondNameTextField.isHidden = false
            confirmPasswordTextField.isHidden = false
            confirmButton.setTitle("Зареєструватися", for: .normal)
        }
        
    }

    
    @IBAction func didPressSignInButton(_ sender: UIButton) {
        /// User pressed Login
        if isLogin {
            
            //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
            let parameters = ["username" : loginTextField.text ?? "", "password" : passwordTextField.text ?? ""] as [String : Any]

            //create the url with URL
            let url = URL(string: "http://localhost:8080/main/login")! //change the url

            postAndGetUuID(url, parameters)

        }
        /// User pressed Register
        if isRegister{
            
            let nameHasNumbers = presenceNumberInString(nameTextField.text)
            let secondNameHasNumbers = presenceNumberInString(secondNameTextField.text)
            
            if nameHasNumbers || secondNameHasNumbers {
                present(noticeAlert(message: "Ім'я та прізвище повинні містити лише літери!"), animated: true, completion: nil)
                
            } else if passwordTextField.text?.count ?? 0 < 6 {
                present(noticeAlert(message: "Пароль повинен містити щонайменше 6 символів!"), animated: true, completion: nil)
                
            } else if passwordTextField.text != confirmPasswordTextField.text {
                present(noticeAlert(message: "Ви ввели різні паролі!"), animated: true, completion: nil)
                
            } else {
                //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
                let parameters = ["user_first_name": nameTextField.text ?? "", "user_second_name": secondNameTextField.text ?? "", "username" : loginTextField.text ?? "", "password" : passwordTextField.text ?? ""] as [String : Any]

                //create the url with URL
                let url = URL(string: "http://localhost:8080/main/registration")! //change the url
                
                postAndGetUuID(url, parameters)
            }
        }
    }
    
    /// Chack presence number in String
    func presenceNumberInString(_ str: String?) -> Bool {
        let numbersRange = str?.rangeOfCharacter(from: .decimalDigits)
        return (numbersRange != nil)
    }
    
    
    func noticeAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okBtn)
        return alert
    }
    
    /// Sends data to serser using URL and get returned data from server
    func postAndGetUuID(_ url: URL, _ parameters: [String : Any]) {
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

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                self.processingReturnedData(dataString)
            }
        })
        task.resume()
    }
    
    /// Chacks if returned data is an error or expected information. Presents alert if it is an error.
    func processingReturnedData(_ dataString: String) {
        if dataString == "User is already exist"{
            DispatchQueue.main.async {
                self.present(self.noticeAlert(message: "Користувач з таким іменем уже існує"), animated: true, completion: nil)
            }
//            print(dataString)
        } else if dataString == "Password is wrong" {
            DispatchQueue.main.async {
                self.present(self.noticeAlert(message: "Неправильний пароль"), animated: true, completion: nil)
            }
//            print(dataString)
        } else if dataString == "User is not exist" {
            DispatchQueue.main.async {
                self.present(self.noticeAlert(message: "Користувач з таким іменем не існує"), animated: true, completion: nil)
            }
//            print(dataString)
        } else{
            /// Transmits the user`s uuID to the settings
            Settings.shared.uuID = dataString
            DispatchQueue.main.async {
                ViewManager.shared.toMainVC()
            }
        }
    }
}
