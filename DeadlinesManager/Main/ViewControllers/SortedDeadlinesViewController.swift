//
//  SortedDeadlinesViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 27.04.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit


enum SortedType {
    case today
    case sheduled
    case forYou
}


class SortedDeadlinesViewController: UIViewController {
    
    /// Main tableView
    @IBOutlet var tableView: UITableView!

    /// Projects in which user participates
    public var allProjects: [Project] = []
    
    /// Array with clouser which contains Project and their deadline. Used for display in tableView
    private var projectArray: [(project: Project, deadlines: [Deadline])] = []
    
    /// Array with clouser which contains day and their deadlines.
    private var sheduledArray: [(date: String, deadlines: [Deadline])] = []
    
    /// In type which deadlines be sorted default is .today
    var sortedType: SortedType = .today
    
    /// Settings singleton
    var settings = Settings.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSortedType()
        setupTableView()
    }
    
    /**
     Setup sorted type
    */
    private func setupSortedType() {
        switch sortedType {
        case .today:
            self.title = "Cьогодні"
            sortDeadlinesForToday()
            break
        case .sheduled:
            self.title = "Заплановано"
        case.forYou:
            self.title = "Для вас"
            sortDeadlinesForYou()
            break
        }
    }
    
    /**
     Setup tableView
     */
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
    }
    

    /**
     Sorting deadline for today
     Add deadlines to projectArray that have todays day month and year or have already missed
     */
    func sortDeadlinesForToday() {
        let todayDate = Date()
        
        for project in allProjects {
            var deadlinesForToday: [Deadline] = []
            for deadline in project.deadlines {
                let deadlineExecutionDate = Date(timeIntervalSince1970: TimeInterval(deadline.deadlineExecutionTime))
                
                let daysBetweenTodayAndExecution = deadlineExecutionDate.days(sinceDate: todayDate) ?? 0
                if daysBetweenTodayAndExecution < 0 || (todayDate.hasSame(.day, as: deadlineExecutionDate) && todayDate.hasSame(.month, as: deadlineExecutionDate) && todayDate.hasSame(.year, as: deadlineExecutionDate)) {
                    deadlinesForToday.append(deadline)
                }
            }
            if !deadlinesForToday.isEmpty {
                projectArray.append((project, deadlinesForToday))
            }
        }
    }
    
    /**
     Sort dealines in which user participates
     */
    func sortDeadlinesForYou() {
        
        for project in allProjects {
            var deadlinesForYou: [Deadline] = []
            for deadline in project.deadlines {
                if let deadlineExecutors = deadline.deadlineExecutors {
                    if deadlineExecutors.contains(where: { user -> Bool in
                        return user.username == settings.login
                    }) {
                        deadlinesForYou.append(deadline)
                    }
                }
            }
            if !deadlinesForYou.isEmpty {
                projectArray.append((project, deadlinesForYou))
            }
        }
    }
    
    
    func sortDeadlineSheduled() {
        var allDeadlines: [Deadline] = []
        for project in allProjects {
            for deadline in project.deadlines {
                allDeadlines.append(deadline)
            }
        }
        
        var sheduleDictionary: [String: [Deadline]] = [:]

    
        for deadline in allDeadlines {
            let deadlineDate = Date(timeIntervalSince1970: TimeInterval(deadline.deadlineExecutionTime))
    
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, d MMMM yyyy"
            

            let deadlineKey = dateFormatter.string(from: deadlineDate)
            
            let deadlinesOptionalForSomeDay = sheduleDictionary[deadlineKey]
            
            if var deadlinesForSomeDay = deadlinesOptionalForSomeDay {
                deadlinesForSomeDay.append(deadline)
                sheduleDictionary[deadlineKey] = deadlinesForSomeDay
            } else {
                sheduleDictionary[deadlineKey] = [deadline]
            }
        }
        
        let dict = sheduleDictionary.sorted { (arg0, arg1) -> Bool in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, d MMMM yyyy"

            guard let timeInterval1 = dateFormatter.date(from: arg0.key) else { return false }
            guard let timeInterval2 = dateFormatter.date(from: arg1.key) else { return false }
            
            return timeInterval1 < timeInterval2
        }
        
        for i in dict {
            sheduledArray.append((date: i.key, deadlines: i.value))
        }
        
        
    }
    
}

// Table view delegate and data source
extension SortedDeadlinesViewController: UITableViewDelegate, UITableViewDataSource {
    
    /**
     TableView func: titleForHeaderInSection
    */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch sortedType {
        case .today, .forYou:
            return projectArray[section].project.projectName
        case .sheduled:
            return sheduledArray[section].date
            
        }
        
    }

    /**
     TableView func: numberOfSections
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        switch sortedType {
        case .today, .forYou:
            return projectArray.count
        case .sheduled:
            return sheduledArray.count
            
        }
    }

    /**
     TableView func: numberOfRowsInSection
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sortedType {
        case .today, .forYou:
            return projectArray[section].deadlines.count
        case .sheduled:
            return sheduledArray[section].deadlines.count
        }
    }

    /**
     TableView func: cellForRowAt
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        
        var deadline: Deadline?
        switch sortedType {
        case .today, .forYou:
            deadline = projectArray[indexPath.section].deadlines[indexPath.row]
            cell.nameLabel.text = deadline?.deadlineName
            cell.detailLabel.text = deadline?.deadlineExecutionTime.toDateString()
        case .sheduled:
            deadline = sheduledArray[indexPath.section].deadlines[indexPath.row]
            cell.nameLabel.text = deadline?.deadlineName
//            cell.detailLabel.text = deadline.pr
        }

        

        cell.numberView.isHidden = true
        return cell
    }
}
