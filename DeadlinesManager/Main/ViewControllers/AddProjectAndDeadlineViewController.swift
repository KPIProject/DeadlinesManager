//
//  AddProjectViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 18.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

protocol AddProjectAndDeadlineViewControllerDelegate {
    func addDeadline(_ deadline: Deadline)
}

class AddProjectAndDeadlineViewController: UIViewController, UITextFieldDelegate, SearchTableViewControllerDelegate {

    var delegate: AddProjectAndDeadlineViewControllerDelegate?
    
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var projectDescriptionTextView: UITextView!
    @IBOutlet weak var addProjectButton: UIButton!
//    @IBOutlet weak var membersTextView: UITextView!
    @IBOutlet weak var deadlineDateTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    /// adding deadline if false
    var isAddProject = true
    var projectID: String = ""
    
    /// information from SearchTableViewController
    private var usersToAddUsernames: [String] = []
    private var usersToAddNames: [String] = []
    
    private let datePicker = UIDatePicker()
    /// date of the deadline
    private var timeIntervalFromDatePicker: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLargeTitleDisplayMode(.always)
        self.title = { () -> String in
            if isAddProject { return "Новий проект" }
            else { return "Нова задача" } }()
        
        addProjectButton.setTitle({ () -> String in
        if isAddProject { return "Додати проект" }
        else { return "Додати задачу" } }(), for: .normal) 
        
        addProjectButton.layer.cornerRadius = CGFloat((Double(addProjectButton.frame.height) ) / 3.5)
        
        setupTableView()
        setupDatePicker()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    
    // MARK: - date Picker funcs
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: true)
        
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localeID!)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
        deadlineDateTextField.inputView = datePicker
        deadlineDateTextField.inputAccessoryView = toolbar
        deadlineDateTextField.text = (Int(Date().timeIntervalSince1970)).toDateString()
    }
    
    @objc func doneAction() {
        timeIntervalFromDatePicker = Int(datePicker.date.timeIntervalSince1970)
        view.endEditing(true)
    }
    
    @objc func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        deadlineDateTextField.text = formatter.string(from: datePicker.date)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        projectNameTextField.resignFirstResponder()
        projectDescriptionTextView.resignFirstResponder()
        return true
    }
    
    
    // MARK: - IBActions
    
    @IBAction func didPressAddMember(_ sender: UIButton) {
        guard let serchVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchTableViewController") as? SearchTableViewController else { return }
        serchVC.delegate = self
        serchVC.usersToAddName = self.usersToAddNames
        serchVC.usersToAddUsername = self.usersToAddUsernames
        serchVC.titleToShow = "Додати учасників:"
        serchVC.isHideSegmentControl = true
        let navigationC = UINavigationController()
        navigationC.viewControllers = [serchVC]
        present(navigationC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(serchVC, animated: true)
        
    }
    
    @IBAction func tapOnScreen(_ sender: UITapGestureRecognizer) {
        projectNameTextField.resignFirstResponder()
        projectDescriptionTextView.resignFirstResponder()
        deadlineDateTextField.resignFirstResponder()
    }
    
    @IBAction func didPressDoneButton(_ sender: UIButton) {
        /// for ability to leave the description field blank
        if projectDescriptionTextView.text.count < 1 {
            projectDescriptionTextView.text = " "
        }
        
        if projectDescriptionTextView.text.count > 7000 {
            present(self.noticeAlert(message: "Занадто великий опис! Опис повинен містити не більше 7000 символів."), animated: true, completion: nil)
        } else if isAddProject {
            
            //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
            let parameters = ["project": ["projectName" : projectNameTextField.text ?? "", "projectDescription" : projectDescriptionTextView.text ?? "", "projectExecutionTime" : timeIntervalFromDatePicker , "projectCreationTime" : Int(Date().timeIntervalSince1970)], "usersToAdd": usersToAddUsernames] as [String : Any]

            //create the url with URL
            let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/createProjectDebug")! //change the url

            postAndGetData(url, parameters)
            
        } else {
            //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
            let parameters = ["deadline": ["deadlineName" : projectNameTextField.text ?? "", "deadlineDescription" : projectDescriptionTextView.text ?? "", "deadlineExecutionTime" : timeIntervalFromDatePicker , "deadlineCreationTime" : Int(Date().timeIntervalSince1970)], "usersToAdd": usersToAddUsernames] as [String : Any]

            //create the url with URL
            let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/\(projectID)/addDeadline")! //change the url

            postAndGetData(url, parameters)
        }
    }
    // MARK: - ВИНЕСТИ
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
            switch error.message {
 
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
            case "Invalid deadlnineName":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Введіть, будь ласка, назву задачі!"), animated: true, completion: nil)
                }
            case "Invalid deadlineDescription":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Немає опису задачі!"), animated: true, completion: nil)
                }
            case "User to add not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Користувач з таким ім'ям не існує!"), animated: true, completion: nil)
                }
            case "User to add is not in this project":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Користувача, якого ви хочете додати нема в цьому проекті"), animated: true, completion: nil)
                }
            default:
                break
            }
        } else {
            if isAddProject && ((try? JSONDecoder().decode(Project.self, from: data)) != nil) {
                DispatchQueue.main.async {
                    ViewManager.shared.toMainVC()
                }
            } else if !isAddProject, let deadline = try? JSONDecoder().decode(Deadline.self, from: data) {
                isAddProject = true
                DispatchQueue.main.async {
                    self.delegate?.addDeadline(deadline)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    // MARK: - SearchTableViewControllerDelegate
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toSearchVC" {
//            let destinationVC = segue.destination as! SearchTableViewController
//            destinationVC.delegate = self
//        }
//    }
    
    func fillTextFieldWithUsers(names: [String], usernames: [String]) {
//        membersTextView.text = usernames.joined(separator: ", ")
        usersToAddUsernames = usernames
        usersToAddNames = names
        tableView.reloadData()
    }

}


extension AddProjectAndDeadlineViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if usersToAddUsernames.count == 0 {
            return 1
        } else {
            return usersToAddUsernames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        
        if usersToAddUsernames.count == 0 {
            cell.nameLabel.text = "Тут ще немає учасників"
            cell.detailLabel.text = "Натисніть ➕, щоб додати"
        } else {
            cell.nameLabel.text = usersToAddUsernames[indexPath.row]
            cell.detailLabel.text = usersToAddNames[indexPath.row]
        }
        cell.numberView.isHidden = true
        cell.arrowView.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Видалити") { (action, view, completion ) in
            self.usersToAddUsernames.remove(at: indexPath.row)
            self.usersToAddNames.remove(at: indexPath.row)
            tableView.reloadData()
            tableView.isEditing = false
        }
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }

    
    
}
