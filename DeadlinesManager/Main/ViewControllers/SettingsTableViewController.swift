//
//  SettingsTableViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 30.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    let settings = Settings.shared
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = #colorLiteral(red: 0.9497330785, green: 0.964420855, blue: 0.9139826894, alpha: 1)
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        
        loginLabel.text = Settings.shared.login
        nameLabel.text = Settings.shared.firstName + " " + Settings.shared.secondName
        
    }

    @IBAction func didPressExitButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Ви дійсно хочете вийти?", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "Підтвердити", style: .destructive, handler: {(_) in
            self.settings.uuID = ""
            self.settings.login = ""
            self.settings.firstName = ""
            self.settings.secondName = ""
            self.settings.creatingTime = 0
            
            deleteAllFromCoreData()
            ViewManager.shared.toLoginVC()
            
        })
        let cancelBtn = UIAlertAction(title: "Скасувати", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true, completion: nil)
        
    }
    
}
