//
//  SettingsTableViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 30.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    /// Label with username
    @IBOutlet weak var loginLabel: UILabel!
    
    /// Label with firstName + secondName
    @IBOutlet weak var nameLabel: UILabel!
    
    /// Settings singleton
    let settings = Settings.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        
        setupUser()
    }
    
    /**
     Setup username and userFi
     */
    private func setupUser() {
        loginLabel.text = Settings.shared.login
        nameLabel.text = Settings.shared.firstName + " " + Settings.shared.secondName
    }
    
    /**
     TableView func: heightForHeaderInSection
    */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    /**
     When user tap to on exit from account.
     Also call alert with options: accept ot deny.
    */
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
    
    /**
     When user tap to on DELETE from account.
     Also call alert with options: accept ot deny.
    */
    @IBAction func didPressDeleteButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Ви дійсно хочете видалити обліковий запис?", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "Підтвердити", style: .destructive, handler: {(_) in
            
            // create the session object
            let session = URLSession.shared
            // create the url with URL
            let url = URL(string: "http://192.168.31.88:8080/\(self.settings.uuID)/deleteUser")!
            // now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            // create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in

                guard error == nil else {
                    return
                }
                if let data = data {
                    guard let answer = try? JSONDecoder().decode(Error.self, from: data) else { return }
                    if answer.type == "Error" {
                        
                        self.present(self.noticeAlert(message: "Сталася помилка при видаленні"), animated: true, completion: nil)
                        
                    } else {
                        self.settings.uuID = ""
                        self.settings.login = ""
                        self.settings.firstName = ""
                        self.settings.secondName = ""
                        self.settings.creatingTime = 0
                        
                        deleteAllFromCoreData()
                        ViewManager.shared.toLoginVC()
                    }
                }
            })
            task.resume()
            
        })
        let cancelBtn = UIAlertAction(title: "Скасувати", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true, completion: nil)
    }
    
}
