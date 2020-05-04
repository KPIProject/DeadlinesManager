//
//  SortedDeadlinesViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 27.04.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class SortedDeadlinesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    public var allProjects: [Project] = []
    public var sortedType: String = ""
    private var projectArray: [(project: Project, deadlines: [Deadline])] = []

    override func viewDidLoad() {
        super.viewDidLoad()

//        newProjectsArray()
        sortForToday()
        print(projectArray)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
    }

    func sortForToday() {
        let today = Date()
        for project in allProjects {
            var deadlines: [Deadline] = []
            for deadline in project.deadlines {
                let deadlineExecutionTime = Date(timeIntervalSince1970: TimeInterval(deadline.deadlineExecutionTime))
                let differ = deadlineExecutionTime.days(sinceDate: today) ?? 0
                if differ < 1 {
                    deadlines.append(deadline)
                }
            }
            if !deadlines.isEmpty {
                projectArray.append((project, deadlines))
            }
        }
    }

    func newProjectsArray() {
        for project in allProjects {
            projectArray.append((project, project.deadlines))
        }
    }
}

extension SortedDeadlinesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let projectName = projectArray[section].project.projectName
        return projectName
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return projectArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectArray[section].deadlines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        let deadline = projectArray[indexPath.section].deadlines[indexPath.row]

        cell.nameLabel.text = deadline.deadlineName
        cell.detailLabel.text = deadline.deadlineExecutionTime.toDateString()

        cell.numberView.isHidden = true
        return cell
    }
}
