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

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = #colorLiteral(red: 0.9497330785, green: 0.964420855, blue: 0.9139826894, alpha: 1)

        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)

        button1.layer.cornerRadius = CGFloat(Double(button1.frame.height) / 3.5)
        button2.layer.cornerRadius = CGFloat(Double(button2.frame.height) / 3.5)
        button3.layer.cornerRadius = CGFloat(Double(button3.frame.height) / 3.5)
        button4.layer.cornerRadius = CGFloat(Double(button4.frame.height) / 3.5)

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

        postAndGetData(url)

        projectArray = fetchingCoreData()
        tableView.reloadData()
    }

    /// Sends data to serser using URL and get returned data from server
    func postAndGetData(_ url: URL) {
        // create the session object
        let session = URLSession.shared

        // now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in

            guard error == nil else {
                return
            }
            if let data = data {
                guard let projects = try? JSONDecoder().decode([Project].self, from: data) else { return }
                updateCoreData(data: projects)
            }
        })
        task.resume()
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

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let project = projectArray[indexPath.row]
        let owner = project.projectOwner
        let ownerName = (owner?.userFirstName ?? "") + " " + (owner?.userSecondName ?? "")
//        let deadlinesNumber =
        cell.nameLabel.text = project.projectName
        cell.detailLabel.text = "Власник: " + ownerName
        cell.numberRightLabel.text = String(project.deadlines.count)
        cell.numberView.isHidden = false

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
//        ViewManager.shared.toDetailVC()
        guard let detailVC = UIStoryboard(name: "ProjectDetails", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProjectDetailsViewController") as? ProjectDetailsViewController else { return }
        DispatchQueue.main.async {
            detailVC.project = self.projectArray[indexPath.row]
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
