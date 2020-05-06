//
//  SearchTableViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 03.04.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

protocol SearchTableViewControllerDelegate {
    func fillTextFieldWithUsers(names: [String], usernames: [String])
}

class SearchTableViewController: UITableViewController, UITextFieldDelegate, UISearchBarDelegate {

    var delegate: SearchTableViewControllerDelegate?
    
    /// User`s first and second names (all list)
    public var usersToAddName: [String] = []
    /// User`s usernames (all list)
    public var usersToAddUsername: [String] = []
    /// User`s usernames deleted (last time)
//    public var usernamesToDelete: [String] = []
    /// User`s usernames to add (last time)
//    public var usernamesToAdd: [String] = []
    
//    public var usersToAdd: [User] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private var filtredUsers: [User] = []
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var searchBarButtonWasTaped: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Почніть вводити логін"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
//        searchController.isActive = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarButtonWasTaped = true
        getDataFromServer()
//        if searchBar.isSearchResultsButtonSelected {}
    }
    
    /// Sends data to serser using URL and get returned data from server
    func getDataFromServer() {
        
        let login = searchController.searchBar.text ?? ""
        
        if self.searchBarButtonWasTaped && login.contains(" "){
            
            self.present(self.noticeAlert(message: "Юзернейм не повинен містити пробілів"), animated: true, completion: nil)
            self.searchBarButtonWasTaped = false
            
        } else {
            guard let url = URL(string: "http://localhost:8080/findByUsername/\(login)") else { return }
            //create the session object
            let session = URLSession.shared

            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

                guard error == nil else {
                    return
                }
                if let data = data {

                    if let error = try? JSONDecoder().decode(Error.self, from: data) {
                        if (error.message == "Users not found") && (self.searchBarButtonWasTaped) {
                            DispatchQueue.main.async {
                                self.present(self.noticeAlert(message: "Юзерів з даним логіном немає"), animated: true, completion: nil)
                                self.searchBarButtonWasTaped = false
                            }
                        }
                    } else {
                        guard let users = try? JSONDecoder().decode([User].self, from: data) else { return }
                        //                updateCoreData(data: projects)
                        self.filtredUsers = users
                        print(self.filtredUsers)
                        DispatchQueue.main.async { self.tableView.reloadData() }
                    }
                }
            })
            task.resume()
        }
        
    }
    
    @IBAction func didPressDone(_ sender: UIBarButtonItem) {
        delegate?.fillTextFieldWithUsers(names: usersToAddName, usernames: usersToAddUsername)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filtredUsers = []

        getDataFromServer()
        tableView.reloadData()
    }
    
//    private func filterContentForSearchText(_ searchText)
    
}

extension SearchTableViewController {
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive {
            return filtredUsers.count
        } else {
            return usersToAddName.count
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        var user: User
        
        if searchController.isActive {
            print("isFilterering")
            user = filtredUsers[indexPath.row]
            cell.textLabel?.text = user.username
            cell.detailTextLabel?.text = user.userFirstName + " " + user.userSecondName
        } else {
            print("NOT isFilterering")
            cell.textLabel?.text = usersToAddUsername[indexPath.row]
            cell.detailTextLabel?.text = usersToAddName[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if searchController.isActive {
            let user = filtredUsers[indexPath.row]
//            usersToAdd.append(user)
            usersToAddName.append(user.userFirstName + " " + user.userSecondName)
            usersToAddUsername.append(user.username )
            searchController.isActive = false
            tableView.reloadData()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if searchController.isActive {
            tableView.isEditing = false
            return nil
        } else {
            let delete = UIContextualAction(style: .destructive, title: "Видалити") { (action, view, completion ) in
                self.usersToAddUsername.remove(at: indexPath.row)
                self.usersToAddName.remove(at: indexPath.row)
//                self.usersToAdd.remove(at: indexPath.row)
                tableView.reloadData()
                tableView.isEditing = false
            
            }
            let config = UISwipeActionsConfiguration(actions: [delete])
            return config
        }
    }
    
}
