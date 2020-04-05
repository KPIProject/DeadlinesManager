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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = project?.projectName
        nameLabel.text = project?.projectName
        descriptionTextView.text = project?.projectDescription
        

    }
    
    @IBAction func didPressMembers(_ sender: UIButton) {
    }
    @IBAction func didPressAddTask(_ sender: UIButton) {
    }
    

}
