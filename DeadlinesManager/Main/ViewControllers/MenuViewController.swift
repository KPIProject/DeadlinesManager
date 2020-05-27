//
//  MenuViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 20.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    /// Table View
    @IBOutlet var tableView: UITableView!
    
    /// Today (Сьогодні) button
    @IBOutlet var button1: UIButton!
    
    /// Sheduled (Заплановано) button
    @IBOutlet var button2: UIButton!
    
    /// For you (Для вас) button
    @IBOutlet var button3: UIButton!
    
    /// Invited (Запрошення) button
    @IBOutlet var button4: UIButton!

    /// Array with UNcompleted projects
    var unCompletedProjects: [Project] = []
    
    /// Array with completed projects
    var completedProjects: [Project] = []
    
    /// False if completed not shown
    private var isShowCompletedProjects = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLargeTitleDisplayMode(.never)
        
        setupTableView()
        setupButtons()
        
        formProjectsArrays()
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        update()
    }
    
    /**
     Make buttons rounded
     */
    private func setupButtons() {
        button1.layer.cornerRadius = CGFloat(Double(button1.frame.height) / 3.5)
        button2.layer.cornerRadius = CGFloat(Double(button2.frame.height) / 3.5)
        button3.layer.cornerRadius = CGFloat(Double(button3.frame.height) / 3.5)
        button4.layer.cornerRadius = CGFloat(Double(button4.frame.height) / 3.5)
    }
    
    /**
     Table View settings
     */
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = #colorLiteral(red: 0.9485785365, green: 0.9502450824, blue: 0.9668951631, alpha: 1)
        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
    }
    
    /**
    Form arrays with projects.
     - array with completed projects
     - array with uncompleted projects
     */
    func formProjectsArrays()  {
        let projects = fetchingCoreData()
        completedProjects = []
        unCompletedProjects = []
        for project in projects {
            if project.completeMark {
                completedProjects.append(project)
            } else {
                unCompletedProjects.append(project)
            }
        }
    }
    
    /**
     Update projects from server when viewDidAppear
    */
    func update() {
        // create the url with URL
        let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/allProjects")!
        postAndGetData(url, httpMethod: "GET")
    }

    /**
     Sends data to serser using URL and get returned data from server
     Recieve array of projects, cast it  and form
    */
    func postAndGetData(_ url: URL, httpMethod: String) {
        // create the session object
        let session = URLSession.shared

        // now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in

            guard error == nil else {
                return
            }
            if let data = data {
                if let projects = try? JSONDecoder().decode([Project].self, from: data){
                    updateCoreData(data: projects){
                        self.formProjectsArrays()
                        self.tableView.reloadData()
                    }
                }
                if let answer = try? JSONDecoder().decode(Error.self, from: data) {
                    self.deleteProject(answer)
                }
            }
        })
        task.resume()
    }
    
    /**
     Function which calls when user need to delete project.
     And if server return error, throw it.
     - Parameter answer: answer from server
    */
    func deleteProject(_ answer: Error) {
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
        case "Deleted":
            DispatchQueue.main.async {
                self.update()
            }
            
        default:
            break
        }
    }
    
    /**
     Button which push `AddProjectAndDeadlineViewController` if needed
     */
    @IBAction func didPressAddProjectButton(_ sender: UIBarButtonItem) {
        guard let addVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddProjectViewController") as? AddProjectAndDeadlineViewController else { return }
        addVC.isAddProject = true
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    /**
     Button which push `SortedDeadlinesViewController` if needed
    */
    @IBAction func didPressTodayButton(_ sender: UIButton) {
        guard let todayVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "SortedDeadlinesViewController") as? SortedDeadlinesViewController else { return }
        todayVC.allProjects = self.unCompletedProjects
        todayVC.sortedType = .today
        self.navigationController?.pushViewController(todayVC, animated: true)
    }

    /**
     Button which push `` if needed
    */
    @IBAction func didPressForYouButton(_ sender: UIButton) {
        guard let todayVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "SortedDeadlinesViewController") as? SortedDeadlinesViewController else { return }
        todayVC.allProjects = self.unCompletedProjects
        todayVC.sortedType = .forYou
        self.navigationController?.pushViewController(todayVC, animated: true)
    }
}


// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    /**
     TableView func: titleForHeaderInSection
     */
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

    /**
     TableView func: numberOfSections
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        if isShowCompletedProjects {
            return 2
        } else {
            return 1
        }
    }
    
    /**
     TableView func: numberOfRowsInSection
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowCompletedProjects {
            switch section {
            case 0:
                return unCompletedProjects.count
            case 1:
                return completedProjects.count + 1
            default:
                return 0
            }
        } else {
            return unCompletedProjects.count + 1
        }
    }

    /**
     TableView func: cellForRowAt
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        
        if !isShowCompletedProjects && indexPath.section == 0 && indexPath.row == unCompletedProjects.count {
            cell.nameLabel.text = "Показати виконані"
            cell.detailLabel.text = ""
            cell.arrowView.isHidden = true
            cell.nameLabel.textAlignment = .center
            cell.numberView.isHidden = true
        } else if isShowCompletedProjects && indexPath.section == 1 && indexPath.row == completedProjects.count{
            cell.nameLabel.text = "Сховати виконані"
            cell.detailLabel.text = ""
            cell.arrowView.isHidden = true
            cell.nameLabel.textAlignment = .center
            cell.numberView.isHidden = true
        } else {
            if indexPath.section == 0 {
                let project = unCompletedProjects[indexPath.row]
                let owner = project.projectOwner
                let ownerName = (owner?.userFirstName ?? "") + " " + (owner?.userSecondName ?? "")
                cell.nameLabel.text = project.projectName
                cell.detailLabel.text = "Власник: " + ownerName
                var deadlinesNumber = 0
                for deadline in project.deadlines {
                    if !deadline.completeMark {
                        deadlinesNumber += 1
                    }
                }
                cell.numberRightLabel.text = String(deadlinesNumber)
            } else if indexPath.section == 1 {
               let project = completedProjects[indexPath.row]
               let owner = project.projectOwner
               let ownerName = (owner?.userFirstName ?? "") + " " + (owner?.userSecondName ?? "")
               cell.nameLabel.text = project.projectName
               cell.detailLabel.text = "Власник: " + ownerName
               var deadlinesNumber = 0
               for deadline in project.deadlines {
                   if !deadline.completeMark {
                       deadlinesNumber += 1
                   }
               }
               cell.numberRightLabel.text = String(deadlinesNumber)
            }
            cell.nameLabel.textAlignment = .left
            cell.arrowView.isHidden = false
            cell.numberView.isHidden = false
        }
        return cell
    }

    /**
     TableView func: didSelectRowAt
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if !isShowCompletedProjects && indexPath.row == unCompletedProjects.count {
            isShowCompletedProjects = true
            tableView.reloadData()
        } else if isShowCompletedProjects && indexPath.row == completedProjects.count{
            isShowCompletedProjects = false
            tableView.reloadData()
        } else {
            guard let detailVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProjectDetailsViewController") as? ProjectDetailsViewController else { return }
            
            if indexPath.section == 0 {
                detailVC.project = self.unCompletedProjects[indexPath.row]
            } else if indexPath.section == 1 {
                detailVC.project = self.completedProjects[indexPath.row]
            }
            tableView.deselectRow(at: indexPath, animated: true)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }
    
    /**
     TableView func: trailingSwipeActionsConfigurationForRowAt
    */
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (indexPath.section == 0 && indexPath.row != unCompletedProjects.count) || (indexPath.section == 1 && indexPath.row != completedProjects.count) {
            let delete = UIContextualAction(style: .destructive, title: "Видалити") { (action, view, completion ) in
                var projectID: String {
                    if indexPath.section == 0 {
                        return String(describing: self.unCompletedProjects[indexPath.row].projectID)
                    } else {
                        return String(describing: self.completedProjects[indexPath.row].projectID)
                    }
                }
                // create the url with URL
                let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(projectID)/deleteProject")!
                self.unCompletedProjects.remove(at: indexPath.row)
                tableView.reloadData()
                self.postAndGetData(url, httpMethod: "DELETE")
                tableView.isEditing = false
            }
            let config = UISwipeActionsConfiguration(actions: [delete])
            return config
        } else {
            return nil
        }
    }
}

