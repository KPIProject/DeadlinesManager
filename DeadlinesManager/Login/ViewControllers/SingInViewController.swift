//
//  ViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 05.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class SingInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrolView: UIScrollView!
    
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
    
    var scrollOffset : CGFloat = 0
    var distance : CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpTextFieldDelegate()
        setUpCorrespondingFields()
        
        
//            print(stackViewHeightConstraint!)
//            let newConstraint = stackViewHeightConstraint.constraintWithMultiplier(0.3)
//            view.removeConstraint(stackViewHeightConstraint)
//            view.addConstraint(newConstraint)
//            view.layoutIfNeeded()
//            stackViewHeightConstraint = newConstraint
 
        confirmButton.layer.cornerRadius = CGFloat((Double(confirmButton.frame.height) ) / 3.5)
    }
    
    
    func setUpTextFieldDelegate() {
        nameTextField.delegate = self
        loginTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        secondNameTextField.delegate = self
    }
    
    
    /// Func adds or removes registration and login fields
    func setUpCorrespondingFields() {
        passwordTextField.layer.borderWidth = 2.0
        passwordTextField.layer.borderColor = #colorLiteral(red: 0.0536134094, green: 0.1874043941, blue: 0.2290870845, alpha: 1)
        passwordTextField.layer.cornerRadius = CGFloat((Double(passwordTextField.frame.height) ) / 3.5)
        loginTextField.layer.borderWidth = 2.0
        loginTextField.layer.borderColor = #colorLiteral(red: 0.0536134094, green: 0.1874043941, blue: 0.2290870845, alpha: 1)
        loginTextField.layer.cornerRadius = CGFloat((Double(loginTextField.frame.height) ) / 3.5)
        
        /// User pressed Login
        if isLogin {
            self.title = "УВІЙТИ"
            let newConstraint = stackViewHeightConstraint.constraintWithMultiplier(0.25)
            view.removeConstraint(stackViewHeightConstraint)
            view.addConstraint(newConstraint)
            view.layoutIfNeeded()
            stackViewHeightConstraint = newConstraint
            loginTextField.placeholder = "  Введіть логін"
            passwordTextField.placeholder = "  Введіть пароль"
//            nameLabel.isHidden = true
//            secondNameLabel.isHidden = true
//            confirmPasswordLabel.isHidden = true
            nameTextField.isHidden = true
            secondNameTextField.isHidden = true
            confirmPasswordTextField.isHidden = true
            confirmButton.setTitle("УВІЙТИ", for: .normal)
        }
        /// User pressed Register
        if isRegister {
            self.title = "РЕЄСТРАЦІЯ"
//           nameLabel.isHidden = false
//           secondNameLabel.isHidden = false
//           confirmPasswordLabel.isHighlighted = false
            nameTextField.isHidden = false
            secondNameTextField.isHidden = false
            confirmPasswordTextField.isHidden = false
            confirmButton.setTitle("ЗАРЕЄСТРУВАТИСЯ", for: .normal)
            
            nameTextField.layer.borderWidth = 2.0
            nameTextField.layer.borderColor = #colorLiteral(red: 0.0536134094, green: 0.1874043941, blue: 0.2290870845, alpha: 1)
            nameTextField.layer.cornerRadius = CGFloat((Double(nameTextField.frame.height) ) / 3.5)
            secondNameTextField.layer.borderWidth = 2.0
            secondNameTextField.layer.borderColor = #colorLiteral(red: 0.0536134094, green: 0.1874043941, blue: 0.2290870845, alpha: 1)
            secondNameTextField.layer.cornerRadius = CGFloat((Double(secondNameTextField.frame.height) ) / 3.5)
            confirmPasswordTextField.layer.borderWidth = 2.0
            confirmPasswordTextField.layer.borderColor = #colorLiteral(red: 0.0536134094, green: 0.1874043941, blue: 0.2290870845, alpha: 1)
            confirmPasswordTextField.layer.cornerRadius = CGFloat((Double(confirmPasswordTextField.frame.height) ) / 3.5)
       }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        secondNameTextField.resignFirstResponder()
        
        return true
    }
    
    
    @objc func keyboardWillHide() {
        scrolView.contentOffset = CGPoint.zero
    }
    
    @IBAction func didPressSignInButton(_ sender: UIButton) {
        /// User pressed Login
        if isLogin {
            
            //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
            let parameters = ["username" : loginTextField.text ?? "", "password" : passwordTextField.text ?? ""] as [String : Any]

            //create the url with URL
            let url = URL(string: "http://192.168.31.88:8080/login")! //change the url

            postAndGetData(url, parameters)

        }
        /// User pressed Register
        if isRegister{
            
            let nameHasNumbers = presenceNumberInString(nameTextField.text)
            let secondNameHasNumbers = presenceNumberInString(secondNameTextField.text)
            
            if nameHasNumbers || secondNameHasNumbers {
                present(noticeAlert(message: "Ім'я та прізвище повинні містити лише літери!"), animated: true, completion: nil)
                
            } else if (passwordTextField.text?.count ?? 0 < 6) && passwordTextField.text?.count ?? 0 != 0 {
                present(noticeAlert(message: "Пароль повинен містити щонайменше 6 символів!"), animated: true, completion: nil)
                
            } else if passwordTextField.text != confirmPasswordTextField.text {
                present(noticeAlert(message: "Ви ввели різні паролі!"), animated: true, completion: nil)
                
            } else {
                //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
                let parameters = ["userFirstName": nameTextField.text ?? "", "userSecondName": secondNameTextField.text ?? "", "username" : loginTextField.text ?? "", "password" : passwordTextField.text ?? ""] as [String : Any]

                //create the url with URL
                let url = URL(string: "http://192.168.31.88:8080/registration")! //change the url
                
                postAndGetData(url, parameters)
            }
        }
    }
    
    /// Chack presence number in String
    func presenceNumberInString(_ str: String?) -> Bool {
        let numbersRange = str?.rangeOfCharacter(from: .decimalDigits)
        return (numbersRange != nil)
    }

    
    /// Sends data to serser using URL and get returned data from server
    func postAndGetData(_ url: URL, _ parameters: [String : Any]) {
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
// MARK: - dataString doesn`t needed
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                self.processingReturnedData(dataString, data)
            }
        })
        task.resume()
    }
    
    /// Chacks if returned data is an error or expected information. Presents alert if it is an error.
    func processingReturnedData(_ dataString: String, _ data: Data) {
//        print(dataString)
        
//        let decoder = JSONDecoder()
        
        if let error = try? JSONDecoder().decode(Error.self, from: data) {
            switch error.message {
            case "User is already exist":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Користувач з таким іменем уже існує. Введіть, будь ласка, інший логін"), animated: true, completion: nil)
                }
            case "Invalid userFirstName":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Введіть, будь ласка, ім'я!"), animated: true, completion: nil)
                }
            case "Invalid userSecondName":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Введіть, будь ласка, прізвище!"), animated: true, completion: nil)
                }
            case "Invalid username":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Введіть, будь ласка, логін!"), animated: true, completion: nil)
                }
            case "Invalid password":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Введіть, будь ласка, пароль!"), animated: true, completion: nil)
                }
            case "User not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Користувач з таким ім'ям не існує!"), animated: true, completion: nil)
                }
            case "Password is wrong":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Неправильний пароль"), animated: true, completion: nil)
                }
            default:
                break
            }
        } else {
            print(dataString)
            guard let signInUser = try? JSONDecoder().decode(User.self, from: data) else { return }
            /// Transmits the user`s uuID to the settings
            Settings.shared.uuID = signInUser.uuid ?? ""
            Settings.shared.firstName = signInUser.userFirstName
            Settings.shared.secondName = signInUser.userSecondName
            Settings.shared.login = signInUser.username
            Settings.shared.creatingTime = Int(signInUser.userCreationTime)
            DispatchQueue.main.async {
                ViewManager.shared.toMainVC()
            }
            print(signInUser.uuid ?? "")
        }
    }
}

extension UIViewController {
     public func noticeAlert(message: String) -> UIAlertController {
         let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
         let okBtn = UIAlertAction(title: "Ok", style: .default, handler: nil)
         alert.addAction(okBtn)
         return alert
     }

}
