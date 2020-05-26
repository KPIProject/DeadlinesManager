//
//  DeadlineDetailsViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 05.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class DeadlineDetailsViewController: UIViewController {
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    
    public var deadline: Deadline?
    private var executors: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
        
        if let deadline = deadline {
            self.title = deadline.deadlineName
            deadlineLabel.text = "   Дата дедлайну: \(deadline.deadlineExecutionTime.toDateString())"
            detailTextView.text = deadline.deadlineDescription
            for user in deadline.deadlineExecutors ?? [] {
                executors.append(user)
            }
            
        }
        
    }
    
    @IBAction func didPressDeadlineExecutorsButton(_ sender: UIButton) {
    }

    func deleteExecutor(_ answer: Error, indexPathRow: Int) {
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
                self.present(self.noticeAlert(message: "У вас немає прав на видалення цього проекту."), animated: true, completion: nil)
            }
        case "User to delete not found":
            DispatchQueue.main.async {
                self.present(self.noticeAlert(message: "Сталася помилка при видалені."), animated: true, completion: nil)
            }
        case "Deadline is not in this project":
            DispatchQueue.main.async {
                self.present(self.noticeAlert(message: "Дедлайн знаходиться не в цьому проекті."), animated: true, completion: nil)
            }
        case "User to delete is not this project":
            DispatchQueue.main.async {
                self.present(self.noticeAlert(message: "Дедлайн знаходиться не в цьому проекті."), animated: true, completion: nil)
            }
        case "Deleted":
            DispatchQueue.main.async {
                print("Deleted")
                self.executors.remove(at: indexPathRow)
                self.tableView.reloadData()
            }
        default:
            break
        }
    }

}


// MARK: - UITableViewDataSource
extension DeadlineDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return executors.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        let user = executors[indexPath.row]
        let userName = user.username
        let name = (user.userFirstName) + " " + (user.userSecondName)
        cell.nameLabel.text = userName
        cell.detailLabel.text = name
        cell.numberView.isHidden = true
        cell.arrowView.isHidden = true

        return cell
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Видалити") { (action, view, completion ) in
            let deadlineProjectID = String(self.deadline?.deadlineProjectID ?? 0)
            let deadlineID = String(self.deadline?.deadlineID ?? 0)
            
            // create the url with URL
            let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(deadlineProjectID)/\(deadlineID)/deleteExecutorFromDeadline/\(self.executors[indexPath.row].username)")!
            
            tableView.reloadData()
            postAndGetData(url, httpMethod: "DELETE") { data in
                if let answer = try? JSONDecoder().decode(Error.self, from: data) {
                    self.deleteExecutor(answer, indexPathRow: indexPath.row)
                }
            }
            tableView.isEditing = false
        }
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
}
