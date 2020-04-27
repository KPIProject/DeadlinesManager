//
//  PrejectDetailsViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 31.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class ProjectDetailsViewController: UIViewController {

    public var project: Project?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: ProjectAndDeadlineTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ProjectAndDeadlineTableViewCell.identifier)
        
        title = project?.projectName
        nameLabel.text = project?.projectName
        descriptionTextView.text = project?.projectDescription
        

    }
    
    // MARK: - use SortingVC
    @IBAction func didPressMembers(_ sender: UIButton) {
        
        
    }
    
    
    @IBAction func didPressAddTask(_ sender: UIButton) {
        guard let addVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddProjectViewController") as? AddProjectViewController else { return }
            
        DispatchQueue.main.async {
            addVC.isAddProject = false
            addVC.projectID = String(self.project?.projectID ?? 0)
            self.navigationController?.pushViewController(addVC, animated: true)
        }
    }
    
}

extension ProjectDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project?.deadlines.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectAndDeadlineTableViewCell", for: indexPath) as! ProjectAndDeadlineTableViewCell
        let deadline = project?.deadlines[indexPath.row]
        let deadlineDate = Date(timeIntervalSince1970: TimeInterval(deadline?.deadlineExecutionTime ?? 0))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        cell.nameLabel.text = deadline?.deadlineName
        cell.detailLabel.text = formatter.string(from: deadlineDate)
        cell.numberView.isHidden = true
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
////        ViewManager.shared.toDetailVC()
//        guard let detailVC = UIStoryboard(name: "ProjectDetails", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProjectDetailsViewController") as? ProjectDetailsViewController else { return }
//        DispatchQueue.main.async {
//            detailVC.project = self.projectArray[indexPath.row]
//            self.navigationController?.pushViewController(detailVC, animated: true)
//        }
//    }
    
}

