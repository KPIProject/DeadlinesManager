//
//  AddProjectViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 18.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class AddProjectViewController: UIViewController {

    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var projectMembersTextField: UITextField!
    @IBOutlet weak var projectDescriptionTextView: UITextView!
    @IBOutlet weak var addProjectButton: UIButton!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(fetchingCoreData())
    }
    
    @IBAction func didPressAddProjectButton(_ sender: UIButton) {
        
        if projectDescriptionTextView.text.count > 7000 {
            present(self.noticeAlert(message: "Занадто великий опис! Опис повинен містити не більше 255 символів."), animated: true, completion: nil)
        } else {
            //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
            let parameters = ["project": ["projectName" : projectNameTextField.text ?? "", "projectDescription" : projectDescriptionTextView.text ?? ""], "usersToAdd": [] ] as [String : Any]

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
//        request.addValue("application/json", forHTTPHeaderField: "Accept")

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

            default:
                break
            }
        } else {
            guard let newProject = try? JSONDecoder().decode(Project.self, from: data) else { return }
            /// Transmits the user`s uuID to the settings
//                Settings.shared.uuID = newProject.uuid
            DispatchQueue.main.async {
//                    ViewManager.shared.toMainVC()
            }
            print(newProject)
        }
    }

//    public func noticeAlert(message: String) -> UIAlertController {
//        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
//        let okBtn = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        alert.addAction(okBtn)
//        return alert
//    }
}
