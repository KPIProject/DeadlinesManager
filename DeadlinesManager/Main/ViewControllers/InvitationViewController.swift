//
//  InvitationViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 27.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class InvitationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var projects: [Project] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getInvitations()
    }
    
    
    /**
     Table View settings
     */
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
    }
    
    /**
     Get projects in which the user was invited from server.
     */
    func getInvitations() {
        let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/getInvitations")!
        postAndGetData(url, httpMethod: "GET") { data in
            self.processingReturnedData(data, indexPath: nil)
        }
    }
    
    /**
     Processing data from server.
     If server returned error, throw it with alert.
     
     Also can process:
        - removes a project from the list if the invitation is accepted or rejected
     */
    func processingReturnedData(_ data: Data, indexPath: IndexPath?) {
        if let answer = try? JSONDecoder().decode(Error.self, from: data) {
            switch answer.message {
            case "User not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Помилка прав доступу."), animated: true, completion: nil)
                }
            case "Project not found":
                DispatchQueue.main.async {
                    self.present(self.noticeAlert(message: "Сталася помилка при видалені."), animated: true, completion: nil)
                }
            case "Done":
                DispatchQueue.main.async {
                    print("Success")
                    self.projects.remove(at: indexPath?.row ?? 0)
                    self.tableView.reloadData()
                }
            default:
                break
            }
        
        } else if let answer = try? JSONDecoder().decode(Project.self, from: data) {
            DispatchQueue.main.async {
                self.projects.remove(at: indexPath?.row ?? 0)
                print(answer)
                self.tableView.reloadData()
            }
            
        } else if let answer = try? JSONDecoder().decode([Project].self, from: data) {
            DispatchQueue.main.async {
                print(answer)
                self.projects = answer
                self.tableView.reloadData()
            }
        }
    }
    
    
}

// MARK: - UITableViewDataSource
extension InvitationViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    /**
     TableView func: numberOfRowsInSection
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if projects.count > 0 {
            return projects.count
        } else {
            return 1
        }
        
    }
    
    /**
     TableView func: cellForRowAt
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        
        if projects.count == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "reuseID")
            cell.textLabel?.text = "У вас немає запрошень."
            cell.textLabel?.textAlignment = .center
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let project = projects[indexPath.row]
            cell.nameLabel.text = project.projectName
            cell.detailLabel.text = project.projectOwner?.username
            cell.nameLabel.textAlignment = .left
            cell.arrowView.isHidden = false
            cell.isUserInteractionEnabled = true
        }
        cell.numberView.isHidden = true
        return cell
    }
    
    /**
     TableView func: trailingSwipeActionsConfigurationForRowAt
    */
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if projects.count > 0 {
            let accept = UIContextualAction(style: .normal, title: "Прийняти") { (action, view, completion) in
            let projectID = String(describing: self.projects[indexPath.row].projectID)
            // create the url with URL
            let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/acceptInvite/\(projectID)")!
            
            tableView.reloadData()
            postAndGetData(url, httpMethod: "POST") { data in
                self.processingReturnedData(data, indexPath: indexPath)
            }
            tableView.isEditing = false
            }
            accept.backgroundColor = #colorLiteral(red: 0.5589603608, green: 0.4478357141, blue: 0.5812303601, alpha: 1)
            let config = UISwipeActionsConfiguration(actions: [accept])
            return config
        } else {
            return nil
        }
    }
    
    /**
     TableView func: leadingSwipeActionsConfigurationForRowAt
    */
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if projects.count > 0 {
            let reject = UIContextualAction(style: .destructive, title: "Відхилити") { (action, view, completion ) in
                let projectID = String(describing: self.projects[indexPath.row].projectID)
                // create the url with URL
                let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/rejectInvite/\(projectID)")!
                
                tableView.reloadData()
                
                postAndGetData(url, httpMethod: "POST") { data in
                    self.processingReturnedData(data, indexPath: indexPath)
                }
                tableView.isEditing = false
            }
            let config = UISwipeActionsConfiguration(actions: [reject])
            return config
        } else {
            return nil
        }
    }
        
    /**
     TableView func: didSelectRowAt
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        guard let detailVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProjectDetailsViewController") as? ProjectDetailsViewController else { return }
            detailVC.project = projects[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            self.navigationController?.pushViewController(detailVC, animated: true)
    }

}
