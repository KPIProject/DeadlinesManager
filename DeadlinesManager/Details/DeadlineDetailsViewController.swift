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
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deadlineNameLabel: UILabel!
    
    
    public var deadline: Deadline?
    private var executors: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        
        doneButton.layer.cornerRadius = CGFloat(Double(doneButton.frame.height) / 3.5)
        deleteButton.layer.cornerRadius = CGFloat(Double(deleteButton.frame.height) / 3.5)
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = #colorLiteral(red: 0.9497330785, green: 0.964420855, blue: 0.9139826894, alpha: 1)

        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
        
        if let deadline = deadline {
            deadlineNameLabel.text = deadline.deadlineName
            deadlineLabel.text = deadline.deadlineExecutionTime.toDateString()
            detailTextView.text = deadline.deadlineDescription
//            var usernamesString: [String] = []
            for user in deadline.deadlineExecutors ?? [] {
                executors.append(user)
            }
            
        }
        
    }
    
    @IBAction func didPressDoneButton(_ sender: UIButton) {
    }
    @IBAction func didPressDeleteButton(_ sender: UIButton) {
    }
    @IBAction func didPressDeadlineExecutorsButton(_ sender: UIButton) {
    }

    func deleteDeadline(_ answer: Error, indexPathRow: Int) {
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
            let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/\(deadlineProjectID)/\(deadlineID)/deleteExecutorFromDeadline/\(self.executors[indexPath.row].username)")!
            
            tableView.reloadData()
            postAndGetData(url, httpMethod: "DELETE") { data in
                if let answer = try? JSONDecoder().decode(Error.self, from: data) {
                    self.deleteDeadline(answer, indexPathRow: indexPath.row)
                }
            }
            tableView.isEditing = false
        }
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
}
