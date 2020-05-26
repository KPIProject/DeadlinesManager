//
//  PrejectDetailsViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 31.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class ProjectDetailsViewController: UIViewController, UITextFieldDelegate, AddProjectAndDeadlineViewControllerDelegate{
    

    public var project: Project?
    private var completedDeadlines: [Deadline] = []
    private var unCompletedDeadlines: [Deadline] = []
    
    /// information for SearchTableViewController
    private var usersToAddUsernames: [String] = []
    private var usersToAddNames: [String] = []
    private var invitedUsersUserames: [String] = []
    private var invitedUsersNames: [String] = []
    private var isShowCompletedDeadlines: Bool = false
    private let textView = UITextView(frame: CGRect.zero)
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var membersButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLargeTitleDisplayMode(.always)
        setupTableView()
        formDeadlinesArrays()
        formUsersArrays()
        reloadData()
        
    }
    
    /// Reload Project information in ProjectDetailsViewController
    func reloadData() {
        title = project?.projectName
        dateLabel.text = project?.projectExecutionTime.toDateString()
        descriptionTextView.text = project?.projectDescription
        membersButton.setTitle(String(usersToAddNames.count), for: .normal)
    }
    
    /// Table View settings
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
    }
    
    /**
    Form arrays with project deadlines.
     - array with completed deadlines
     - array with uncompleted deadlines
     */
    func formDeadlinesArrays()  {
        if let deadlines = project?.deadlines {
            for deadline in deadlines{
                if deadline.completeMark {
                    completedDeadlines.append(deadline)
                } else {
                    unCompletedDeadlines.append(deadline)
                }
            }
        }
    }
    
    /**
    Form arrays with project users.
     - array with Usernames
     - array with Names
     */
    func formUsersArrays() {
        if let users = project?.projectUsers {
            for user in users {
                usersToAddUsernames.append(user.username)
                usersToAddNames.append(user.userFirstName + " " + user.userSecondName)
            }
        }
        if let usersInvited = project?.projectUsersInvited {
            for user in usersInvited {
                invitedUsersUserames.append(user.username)
                invitedUsersNames.append(user.userFirstName + " " + user.userSecondName)
            }
        }
    }
    
    /**
    Presents SearchTableViewController with list of users after press Members Button.
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
        searchVC.invitedName = self.invitedUsersNames
        searchVC.invitedUsername = self.invitedUsersUserames
        searchVC.titleToShow = ""
        searchVC.isHideSegmentControl = false
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
        addVC.delegate = self
        addVC.isAddProject = false
        addVC.projectID = String(self.project?.projectID ?? 0)
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    func addDeadline(_ deadline: Deadline) {
        self.unCompletedDeadlines.append(deadline)
        tableView.reloadData()
    }
    
    @IBAction func didPressEditButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let editProject = UIAlertAction(title: "Редагувати проект", style: .default) { (_) in
            self.changeProjectDescription()
        }
        let completeProject = UIAlertAction(title: "Помітити як виконаний", style: .default) { (_) in
            self.setCompleteMack()
        }
        let deleteProject =  UIAlertAction(title: "Видалити проект", style: .destructive) { (_) in
            
        }
        let cansel =  UIAlertAction(title: "Скасувати", style: .cancel)
        alert.addAction(editProject)
        alert.addAction(completeProject)
        alert.addAction(deleteProject)
        alert.addAction(cansel)
        present(alert, animated: true, completion: nil)
    }
    
    func setCompleteMack() {
        let projectID = String(describing: self.project?.projectID ?? 0)
        let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(projectID)/setProjectComplete")!
        postAndGetData(url, httpMethod: "POST") { data in
            self.processingReturnedData(data, indexPath: nil)
        }
    }
    
    func changeProjectDescription() {
        guard let editVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditProjectViewController") as? EditProjectViewController else { return }
        editVC.project = project
        editVC.delegate = self
        
        let navigationC = UINavigationController()
        navigationC.viewControllers = [editVC]
        present(navigationC, animated: true, completion: nil)
    }
    
    
    func processingReturnedData(_ data: Data, indexPath: IndexPath?) {
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
                    if indexPath?.section == 0 {
                        self.unCompletedDeadlines.remove(at: indexPath?.row ?? 0)
                    } else {
                        self.completedDeadlines.remove(at: indexPath?.row ?? 0)
                    }
                    self.tableView.reloadData()
            }
            default:
                break
            }
        
        } else if let answer = try? JSONDecoder().decode(Project.self, from: data) {
            print(answer)
            project = answer
            DispatchQueue.main.async {
                if self.project?.completeMark ?? false {
                    self.present(self.noticeAlert(message: "Проект відмічений як виконаний"), animated: true, completion: nil)
                } else {
                    self.reloadData()
                }
            }
        } else if let answer = try? JSONDecoder().decode(Deadline.self, from: data) {
            DispatchQueue.main.async {
                self.completedDeadlines.append(answer)
                self.unCompletedDeadlines.remove(at: indexPath?.row ?? 0)
                self.tableView.reloadData()
            }
        }
    }
    
    
}


extension ProjectDetailsViewController: SearchTableViewControllerDelegate{
    
    func fillTextFieldWithUsers(names: [String], usernames: [String]) {
        if usernames != usersToAddUsernames {
            let (usersToAdd, usersToDelete) = addDeleteUsers(usernames)
            let projectID = String(describing: self.project?.projectID ?? 0)
            
            for user in usersToAdd {
                // create the url with URL
                let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(projectID)/addUserToProjectDebug/\(user)")!
                postAndGetData(url, httpMethod: "POST") { data in
                    self.processingReturnedData(data, indexPath: nil)
                }
            }
            for user in usersToDelete {
                // create the url with URL
                let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(projectID)/deleteUserFromProject/\(user)")!
                postAndGetData(url, httpMethod: "DELETE") { data in
                    self.processingReturnedData(data, indexPath: nil)
                }
            }
            usersToAddUsernames = usernames
            usersToAddNames = names
            reloadData()
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
        let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(projectID)/editProject")!
        postDataWithParameters(url, parameters) { data in
            self.processingReturnedData(data, indexPath: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension ProjectDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Невиконані"
        case 1:
            return "Виконані"
        default:
            return nil
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if isShowCompletedDeadlines {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowCompletedDeadlines {
            switch section {
            case 0:
                return unCompletedDeadlines.count
            case 1:
                return completedDeadlines.count + 1
            default:
                return 0
            }
        } else {
            return unCompletedDeadlines.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        
        if !isShowCompletedDeadlines && indexPath.section == 0 && indexPath.row == unCompletedDeadlines.count {
            cell.nameLabel.text = "Показати виконані"
            cell.detailLabel.text = ""
            cell.arrowView.isHidden = true
            cell.nameLabel.textAlignment = .center
        } else if isShowCompletedDeadlines && indexPath.section == 1 && indexPath.row == completedDeadlines.count{
            cell.nameLabel.text = "Сховати виконані"
            cell.detailLabel.text = ""
            cell.arrowView.isHidden = true
            cell.nameLabel.textAlignment = .center
        } else {
            if indexPath.section == 0 {
                let deadline = unCompletedDeadlines[indexPath.row]
                cell.nameLabel.text = deadline.deadlineName
                cell.detailLabel.text = deadline.deadlineExecutionTime.toDateString()
            } else if indexPath.section == 1 {
                let deadline = completedDeadlines[indexPath.row]
                cell.nameLabel.text = deadline.deadlineName
                cell.detailLabel.text = deadline.deadlineExecutionTime.toDateString()
            }
            cell.nameLabel.textAlignment = .left
            cell.arrowView.isHidden = false
        }
        cell.numberView.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (indexPath.section == 0 && indexPath.row != unCompletedDeadlines.count) || (indexPath.section == 1 && indexPath.row != completedDeadlines.count) {
            let delete = UIContextualAction(style: .destructive, title: "Видалити") { (action, view, completion ) in
                let projectID = String(describing: self.project?.projectID ?? 0)
                var deadlineID: String {
                    if indexPath.section == 0 {
                        return String(describing: self.unCompletedDeadlines[indexPath.row].deadlineID)
                    } else {
                        return String(describing: self.completedDeadlines[indexPath.row].deadlineID)
                    }
                }
                // create the url with URL
                let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(projectID)/\(deadlineID)/deleteDeadline")!
                
                tableView.reloadData()
                
                postAndGetData(url, httpMethod: "DELETE") { data in
                    self.processingReturnedData(data, indexPath: indexPath)
                }
                tableView.isEditing = false
            }
            let config = UISwipeActionsConfiguration(actions: [delete])
            return config
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 && indexPath.row != unCompletedDeadlines.count {
            let setCompleteMark = UIContextualAction(style: .normal, title: "Виконано") { (action, view, completion) in
            let projectID = String(describing: self.project?.projectID ?? 0)
            let deadlineID = String(describing: self.unCompletedDeadlines[indexPath.row].deadlineID)
            // create the url with URL
            let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(projectID)/\(deadlineID)/setDeadlineComplete")!
            
            tableView.reloadData()
            postAndGetData(url, httpMethod: "POST") { data in
                self.processingReturnedData(data, indexPath: indexPath)
            }
            tableView.isEditing = false
            }
            setCompleteMark.backgroundColor = #colorLiteral(red: 0.5589603608, green: 0.4478357141, blue: 0.5812303601, alpha: 1)
            let config = UISwipeActionsConfiguration(actions: [setCompleteMark])
            return config
        } else {
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if !isShowCompletedDeadlines && indexPath.row == unCompletedDeadlines.count {
            isShowCompletedDeadlines = true
            tableView.reloadData()
        } else if isShowCompletedDeadlines && indexPath.row == completedDeadlines.count{
            isShowCompletedDeadlines = false
            tableView.reloadData()
        } else {
            guard let detailVC = UIStoryboard(name: "ProjectDetails", bundle: Bundle.main).instantiateViewController(withIdentifier: "DeadlineDetailsViewController") as? DeadlineDetailsViewController else { return }
            
            if indexPath.section == 0 {
                detailVC.deadline = self.unCompletedDeadlines[indexPath.row]
            } else if indexPath.section == 1 {
                detailVC.deadline = self.completedDeadlines[indexPath.row]
            }
            tableView.deselectRow(at: indexPath, animated: true)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    
}


