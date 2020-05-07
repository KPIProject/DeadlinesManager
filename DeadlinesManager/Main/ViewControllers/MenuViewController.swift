//
//  MenuViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 20.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!

    var projectArray: [Project] = []
//    var needApdate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLargeTitleDisplayMode(.never)
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = #colorLiteral(red: 0.9485785365, green: 0.9502450824, blue: 0.9668951631, alpha: 1)

        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)

        button1.layer.cornerRadius = CGFloat(Double(button1.frame.height) / 3.5)
        button2.layer.cornerRadius = CGFloat(Double(button2.frame.height) / 3.5)
        button3.layer.cornerRadius = CGFloat(Double(button3.frame.height) / 3.5)
        button4.layer.cornerRadius = CGFloat(Double(button4.frame.height) / 3.5)

        projectArray = fetchingCoreData()
        update()
    }
    

    override func viewDidAppear(_ animated: Bool) {
//        print("YES")
        update()
        print(projectArray)
//        if needApdate{
//            update()
//            needApdate = false
//        }
    }

//    override func viewWillAppear(_ animated: Bool) {
//        print("YES")
//        if needApdate{
//            update()
//            needApdate = false
//        }
//    }

    func update() {
        // create the url with URL
        let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/allProjects")!

        postAndGetData(url, httpMethod: "GET")

//        projectArray = fetchingCoreData()
//        tableView.reloadData()
    }

    /// Sends data to serser using URL and get returned data from server
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
                        self.projectArray = fetchingCoreData()
                        
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

    @IBAction func didPressTodayButton(_ sender: UIButton) {
        guard let todayVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "SortedDeadlinesViewController") as? SortedDeadlinesViewController else { return }
        DispatchQueue.main.async {
            todayVC.allProjects = self.projectArray
            self.navigationController?.pushViewController(todayVC, animated: true)
        }
    }

    @IBAction func didPressForYouButton(_ sender: UIButton) {
    }
}

// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        let project = projectArray[indexPath.row]
        let owner = project.projectOwner
        let ownerName = (owner?.userFirstName ?? "") + " " + (owner?.userSecondName ?? "")
        cell.nameLabel.text = project.projectName
        cell.detailLabel.text = "Власник: " + ownerName
        cell.numberRightLabel.text = String(project.deadlines.count)
        cell.numberView.isHidden = false

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)

        guard let detailVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProjectDetailsViewController") as? ProjectDetailsViewController else { return }
        detailVC.project = self.projectArray[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(detailVC, animated: true)
        
        
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Видалити") { (action, view, completion ) in
            
            // create the url with URL
            let url = URL(string: "http://localhost:8080/\(Settings.shared.uuID)/\(self.projectArray[indexPath.row].projectID)/deleteProject")!
            self.projectArray.remove(at: indexPath.row)
            tableView.reloadData()
            self.postAndGetData(url, httpMethod: "DELETE")
            tableView.isEditing = false
        }
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
}

