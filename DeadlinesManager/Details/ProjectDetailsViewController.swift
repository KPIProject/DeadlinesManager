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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.largeTitleDisplayMode = .always
//        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
        
        title = project?.projectName
        nameLabel.text = project?.projectName
        descriptionTextView.text = project?.projectDescription
        
        if let project = project {
            deadlines = project.deadlines
        }
        
        formUsersArrays()
    }
    
    func formUsersArrays() {
        guard let users = project?.projectUsers else { return }
        for user in users {
            usersToAddUsernames.append(user.username)
            usersToAddNames.append(user.userFirstName + " " + user.userSecondName)
        }
    }
    
    @IBAction func didPressMembers(_ sender: UIButton) {
        guard let serchVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchTableViewController") as? SearchTableViewController else { return }
        serchVC.delegate = self
        DispatchQueue.main.async {
            serchVC.usersToAddName = self.usersToAddNames
            serchVC.usersToAddUsername = self.usersToAddUsernames
            self.navigationController?.pushViewController(serchVC, animated: true)
        }
    }
    
    
    @IBAction func didPressAddTask(_ sender: UIButton) {
        guard let addVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddProjectViewController") as? AddProjectViewController else { return }
            
        DispatchQueue.main.async {
            addVC.isAddProject = false
            addVC.projectID = String(self.project?.projectID ?? 0)
            self.navigationController?.pushViewController(addVC, animated: true)
        }
    }
    
    
    
    func processingReturnedData(_ data: Data, indexPathRow: Int) {
        if let answer = try? JSONDecoder().decode(Error.self, from: data){
            switch answer.message {
            case "User not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Сталася помилка при видалені."), animated: true, completion: nil)
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
                    self.deadlines.remove(at: indexPathRow)
                    self.tableView.reloadData()
            }
            default:
                break
            }
        
        } else if let answer = try? JSONDecoder().decode(Project.self, from: data) {
            print(answer)
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
                    self.processingReturnedData(data, indexPathRow: 0)
                }
            }
            for user in usersToDelete {
                // create the url with URL
                let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/\(projectID)/deleteUserFromProject/\(user)")!
                postAndGetData(url, httpMethod: "DELETE") { data in
                    self.processingReturnedData(data, indexPathRow: 0)
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
            
//            self.deadlines.remove(at: indexPath.row)
            tableView.reloadData()
            
            postAndGetData(url, httpMethod: "DELETE") { data in
//                if let answer = try? JSONDecoder().decode(Error.self, from: data) {
//
//                }
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
        DispatchQueue.main.async {
            detailVC.deadline = self.deadlines[indexPath.row]
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
}

