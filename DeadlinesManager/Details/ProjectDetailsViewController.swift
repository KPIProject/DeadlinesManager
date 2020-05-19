//
//  PrejectDetailsViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 31.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class ProjectDetailsViewController: UIViewController, UITextFieldDelegate {
    

    public var project: Project?
    private var deadlines: [Deadline] = []
    
    /// information for SearchTableViewController
    private var usersToAddUsernames: [String] = []
    private var usersToAddNames: [String] = []
    
    private let textView = UITextView(frame: CGRect.zero)
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLargeTitleDisplayMode(.always)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
        
        title = project?.projectName
        dateLabel.text = project?.projectExecutionTime.toDateString()
        descriptionTextView.text = project?.projectDescription
        
        if let project = project {
            deadlines = project.deadlines
        }
        
        formUsersArrays()
    }
    

    /// Form arrays with project users
    ///
    ///     - array with Usernames
    ///     - array with Names
    func formUsersArrays() {
        guard let users = project?.projectUsers else { return }
        for user in users {
            usersToAddUsernames.append(user.username)
            usersToAddNames.append(user.userFirstName + " " + user.userSecondName)
        }
    }
    
    /**
        Presents SearchTableViewController with list of users after press Members Button
     
            Transmits information:
                - usersToAddName (user`s names)
                - usersToAddUsername (user`s usernames)
                - titleToShow (title)
     
     */
    @IBAction func didPressMembers(_ sender: UIButton) {
        guard let searchVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchTableViewController") as? SearchTableViewController else { return }
        searchVC.delegate = self
        searchVC.usersToAddName = self.usersToAddNames
        searchVC.usersToAddUsername = self.usersToAddUsernames
        searchVC.titleToShow = "Учасники проекта"
        
        let navigationC = UINavigationController()
        
        navigationC.viewControllers = [searchVC]
        
        present(navigationC, animated: true, completion: nil)
    }
    
    /**
    Push DeadlineDetailsViewController  press Add Task Button
    - Parameters:
        - sender: Add Task Button

   Transmits information:
       - usersToAddName (user`s names)
       - usersToAddUsername (user`s usernames)
       - titleToShow (title)
    
    */
    @IBAction func didPressAddTask(_ sender: UIButton) {
        guard let addVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddProjectViewController") as? AddProjectAndDeadlineViewController else { return }
            
        addVC.isAddProject = false
        addVC.projectID = String(self.project?.projectID ?? 0)
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    @IBAction func didPressEditButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Змінити", message: nil, preferredStyle: .actionSheet)
//        let editProjectName = UIAlertAction(title: "Назву", style: .default) { (_) in
//            self.changeProjectName()
//        }
//        let editProjectDeadlineData = UIAlertAction(title: "Дату дедлайну", style: .default) { (_) in
//
//        }
//        let editProjectDescription = UIAlertAction(title: "Редагувати опис", style: .default) { (_) in
//            self.changeProjectDescription()
//        }
        let editProject = UIAlertAction(title: "Редагувати проект", style: .default) { (_) in
            self.changeProjectDescription()
        }
        let deleteProject =  UIAlertAction(title: "Видалити проект", style: .destructive) { (_) in
            
        }
        let cansel =  UIAlertAction(title: "Скасувати", style: .cancel)
//        alert.addAction(editProjectName)
//        alert.addAction(editProjectDeadlineData)
//        alert.addAction(editProjectDescription)
        alert.addAction(editProject)
        alert.addAction(deleteProject)
        alert.addAction(cansel)
        present(alert, animated: true, completion: nil)
    }
    
    func changeProjectDescription() {
//        let alertController = UIAlertController(title: "Feedback \n\n\n\n\n", message: nil, preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
//            alertController.view.removeObserver(self, forKeyPath: "bounds")
//        }
//        alertController.addAction(cancelAction)
//
//        let saveAction = UIAlertAction(title: "Submit", style: .default) { (action) in
//            let enteredText = self.textView.text
//            alertController.view.removeObserver(self, forKeyPath: "bounds")
//        }
//        alertController.addAction(saveAction)
//
//        alertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
//        textView.backgroundColor = UIColor.white
//        textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
//        alertController.view.addSubview(self.textView)
//
//        self.present(alertController, animated: true, completion: nil)
        
        guard let editVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditProjectViewController") as? EditProjectViewController else { return }
        editVC.project = project
        editVC.delegate = self
        
        
        let navigationC = UINavigationController()
        navigationC.viewControllers = [editVC]
        present(navigationC, animated: true, completion: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds"{
            if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
                let margin: CGFloat = 8
                let xPos = rect.origin.x + margin
                let yPos = rect.origin.y + 54
                let width = rect.width - 2 * margin
                let height: CGFloat = 90

                textView.frame = CGRect.init(x: xPos, y: yPos, width: width, height: height)
            }
        }
    }
    
    func changeProjectName() {
        let alert = UIAlertController(title: "Змінити назву", message: nil, preferredStyle: .alert)
        alert.addTextField { (_ textField: UITextField) -> () in
            textField.text = self.project?.projectName
            textField.textAlignment = .center
        }
        let save = UIAlertAction(title: "Зберегти", style: .default) { (_) in
            
        }
        let cansel = UIAlertAction(title: "Скасувати", style: .cancel)
        alert.addAction(save)
        alert.addAction(cansel)
        present(alert, animated: true, completion: nil)
    }
    
    func processingReturnedData(_ data: Data, indexPathRow: Int?) {
        if let answer = try? JSONDecoder().decode(Error.self, from: data){
            switch answer.message {
            case "User not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Помилка прав доступу."), animated: true, completion: nil)
                }
            case "Project not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Сталася помилка при видалені."), animated: true, completion: nil)
                }
            case "Invalid project owner":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "У вас немає прав на дану дію."), animated: true, completion: nil)
                }
            case "Deadline not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Сталася помилка при видалені."), animated: true, completion: nil)
            }
            case "Deadline is not in this project":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Дедлайн знаходиться не в цьому проекті."), animated: true, completion: nil)
            }
            case "User to add not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Користувача, якого ви збираєтесь додати, не існує."), animated: true, completion: nil)
            }
            case "User owner not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Користувача, який керує цим проектом, не існує."), animated: true, completion: nil)
            }
            case "User is already in this project":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Юзер, якого ви хочете додати, вже в цьому проекті."), animated: true, completion: nil)
            }
            case "User owner cant be invited to project":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Неможливо запросити у проект самого себе."), animated: true, completion: nil)
            }
            case "Deleted":
                DispatchQueue.main.async {
                    print("Deleted")
                    self.deadlines.remove(at: indexPathRow ?? 0)
                    self.tableView.reloadData()
            }
            default:
                break
            }
        
        } else if let answer = try? JSONDecoder().decode(Project.self, from: data) {
            print(answer)
            project = answer
//        } else {
//            let dataString = String(data: data, encoding: .utf8)
//            print(dataString)
        }
    }
    
    
}

// MARK: - зробить reload data для VC (щоб обновлять після редагування)

extension ProjectDetailsViewController: SearchTableViewControllerDelegate{
    func fillTextFieldWithUsers(names: [String], usernames: [String]) {
        if usernames != usersToAddUsernames {
            let (usersToAdd, usersToDelete) = addDeleteUsers(usernames)
            let projectID = String(describing: self.project?.projectID ?? 0)
            
            for user in usersToAdd {
                // create the url with URL
                let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/\(projectID)/addUserToProjectDebug/\(user)")!
                postAndGetData(url, httpMethod: "POST") { data in
                    self.processingReturnedData(data, indexPathRow: nil)
                }
            }
            for user in usersToDelete {
                // create the url with URL
                let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/\(projectID)/deleteUserFromProject/\(user)")!
                postAndGetData(url, httpMethod: "DELETE") { data in
                    self.processingReturnedData(data, indexPathRow: nil)
                }
            }
            
            
            usersToAddUsernames = usernames
            usersToAddNames = names
        }
    }
    
    func addDeleteUsers(_ users: [String]) -> (usersToAdd: [String], usersToDelete: [String]) {
        var usersToAdd: [String] = []
        var usersToDelete: [String] = []
        
        for userName in users {
            if !usersToAddUsernames.contains(userName) {
                usersToAdd.append(userName)
            }
        }
        for userName in usersToAddUsernames {
            if !users.contains(userName) {
                usersToDelete.append(userName)
            }
        }
        return (usersToAdd: usersToAdd, usersToDelete: usersToDelete)
    }
}

extension ProjectDetailsViewController: EditProjectViewControllerDelegate {
    func transmitEditDeadlineInformation(parameters: [String : Any]) {
        let projectID = String(describing: self.project?.projectID ?? 0)
        let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/\(projectID)/editProject")!
        postDataWithParameters(url, parameters) { data in
            self.processingReturnedData(data, indexPathRow: nil)
        }
    }
    
}


extension ProjectDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deadlines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        let deadline = deadlines[indexPath.row]
        let deadlineDate = Date(timeIntervalSince1970: TimeInterval(deadline.deadlineExecutionTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        cell.nameLabel.text = deadline.deadlineName
        cell.detailLabel.text = formatter.string(from: deadlineDate)
        cell.numberView.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Видалити") { (action, view, completion ) in
            let projectID = String(describing: self.project?.projectID ?? 0)
            let deadlineID = String(describing: self.deadlines[indexPath.row].deadlineID)
            // create the url with URL
            let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/\(projectID)/\(deadlineID)/deleteDeadline")!
            
            tableView.reloadData()
            
            postAndGetData(url, httpMethod: "DELETE") { data in
                self.processingReturnedData(data, indexPathRow: indexPath.row)
            }
            tableView.isEditing = false
        }
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
//        ViewManager.shared.toDetailVC()
        guard let detailVC = UIStoryboard(name: "ProjectDetails", bundle: Bundle.main).instantiateViewController(withIdentifier: "DeadlineDetailsViewController") as? DeadlineDetailsViewController else { return }
        detailVC.deadline = self.deadlines[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
}


