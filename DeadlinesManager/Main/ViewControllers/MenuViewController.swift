//
//  MenuViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 20.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    var projectArray: [Project] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = #colorLiteral(red: 0.9497330785, green: 0.964420855, blue: 0.9139826894, alpha: 1)
        
        button1.layer.cornerRadius = CGFloat((Double(button1.frame.height) ) / 3.5)
        button2.layer.cornerRadius = CGFloat((Double(button2.frame.height) ) / 3.5)
        button3.layer.cornerRadius = CGFloat((Double(button3.frame.height) ) / 3.5)
        button4.layer.cornerRadius = CGFloat((Double(button4.frame.height) ) / 3.5)

        //declare parameter as a dctionary which contains string as key and value combination. considering inputs are valid
//        let parameters = ["projectName" : projectNameTextField.text ?? "", "projectDescription" : projectDescriptionTextView.text ?? ""] as [String : Any]

        //create the url with URL
        let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/allProjects")!

        postAndGetData(url)
        
        projectArray = fetchingCoreData()
//        print(projectArray)
    }
    

    
    /// Sends data to serser using URL and get returned data from server
        func postAndGetData(_ url: URL) {
            //create the session object
            let session = URLSession.shared

            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
//            do {
//                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
//            } catch let error {
//                print(error.localizedDescription)
//            }

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.addValue("application/json", forHTTPHeaderField: "Accept")

            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

                guard error == nil else {
                    return
                }

                if let data = data {
                    guard let newProject = try? JSONDecoder().decode([Project].self, from: data) else { return }
                    updateCoreData(data: newProject)
                    
                }
            })
            task.resume()
        }
    


}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = projectArray[indexPath.row].projectName
        let owner = projectArray[indexPath.row].projectOwner
        let ownerName = (owner?.userFirstName ?? "") + " " + (owner?.userSecondName ?? "")
        cell.detailTextLabel?.text = "Власник: " + ownerName
        return cell
    }
    
}
