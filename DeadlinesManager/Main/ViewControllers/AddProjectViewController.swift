//
//  AddProjectViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 18.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class AddProjectViewController: UIViewController, UITextFieldDelegate, SearchTableViewControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var projectDescriptionTextView: UITextView!
    @IBOutlet weak var addProjectButton: UIButton!
    @IBOutlet weak var membersTextView: UITextView!
    @IBOutlet weak var deadlineDateTextField: UITextField!
    
    private var usersToAddUuid: [String] = []
    
    let datePicker = UIDatePicker()
    var timeIntervslFromDatePicker: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deadlineDateTextField.inputView = datePicker
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: true)
        
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localeID!)
        deadlineDateTextField.inputAccessoryView = toolbar
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    @objc func doneAction() {
        timeIntervslFromDatePicker = Int(datePicker.date.timeIntervalSince1970)
        view.endEditing(true)
    }
    
    @objc func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        deadlineDateTextField.text = formatter.string(from: datePicker.date)
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        projectNameTextField.resignFirstResponder()
    }
    
    // MARK: - IBActions
    @IBAction func tapOnScreen(_ sender: UITapGestureRecognizer) {
        projectNameTextField.resignFirstResponder()
        projectDescriptionTextView.resignFirstResponder()
        deadlineDateTextField.resignFirstResponder()
    }
    
    @IBAction func didPressAddProjectButton(_ sender: UIButton) {
        
        if projectDescriptionTextView.text.count > 7000 {
            present(self.noticeAlert(message: "Занадто великий опис! Опис повинен містити не більше 7000 символів."), animated: true, completion: nil)
        } else {
            //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
            let parameters = ["project": ["projectName" : projectNameTextField.text ?? "", "projectDescription" : projectDescriptionTextView.text ?? "", "projectExecutionTime" : timeIntervslFromDatePicker , "projectCreationTime" : Int(Date().timeIntervalSince1970)], "usersToAdd": usersToAddUuid] as [String : Any]

            //create the url with URL
            let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/createProject")! //change the url

            postAndGetData(url, parameters)
            
        }
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

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                self.processingReturnedData(dataString, data)
            }
        })
        task.resume()
    }
    
    
    /// Chacks if returned data is an error or expected information. Presents alert if it is an error.
    func processingReturnedData(_ dataString: String, _ data: Data) {
        print(dataString)
//        let decoder = JSONDecoder()
        
        if let error = try? JSONDecoder().decode(Error.self, from: data){
            switch error.errorMessage {
 
            case "Invalid projectName":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Введіть, будь ласка, назву проекта!"), animated: true, completion: nil)
                }
            case "User not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Користувач з таким ім'ям не існує!"), animated: true, completion: nil)
                }
            case "nvalid projectDescription":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Немає опису проекта!"), animated: true, completion: nil)
                }

            default:
                break
            }
        } else {
            if (try? JSONDecoder().decode(Project.self, from: data)) != nil {
                DispatchQueue.main.async {
                    ViewManager.shared.toMainVC()
                }
            }
        }
    }
    
    
    // MARK: - SearchTableViewControllerDelegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchVC" {
            let destinationVC = segue.destination as! SearchTableViewController
            destinationVC.delegate = self
        }
    }
    
    func fillTextFieldWithUsers(usersNames: [String], usersUuid: [String]) {
        membersTextView.text = usersNames.joined(separator: ", ")
        usersToAddUuid = usersUuid
    }

}
