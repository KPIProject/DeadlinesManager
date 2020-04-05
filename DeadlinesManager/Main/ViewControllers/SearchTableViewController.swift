//
//  SearchTableViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 03.04.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

protocol SearchTableViewControllerDelegate {
    func fillTextFieldWithUsers(usersNames: [String], usersUuid: [String])
}

class SearchTableViewController: UITableViewController, UITextFieldDelegate, UISearchBarDelegate {

    var delegate: SearchTableViewControllerDelegate?
    
    public var usersToAddName: [String] = []
    public var usersToAddUuID: [String] = []
    var usersToAdd: [User] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private var filtredUsers: [User] = []
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFilterering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    private var searchBarButtonWasTaped: Bool = false
    
//    @IBOutlet weak var doneButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Почніть вводити логін"
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
                        if (error.errorMessage == "Users not found") && (self.searchBarButtonWasTaped) {
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
//        guard let addProjectVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddProjectViewController") as? AddProjectViewController else { return }
//        addProjectVC.usersToAddUuid = usersToAddUuID
//        addProjectVC.usersToAddUsername = usersToAddName
//
//        self.dismiss(animated: true, completion: nil)
        delegate?.fillTextFieldWithUsers(usersNames: usersToAddName, usersUuid: usersToAddUuID)
        
        self.navigationController?.popViewController(animated: true)

    }
    
    
}

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filtredUsers = []
//        guard let url = URL(string: "http://localhost:8080/findByUsername/\(searchController.searchBar.text ?? "")") else { return }
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
            return usersToAdd.count
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        var user: User
        
        if searchController.isActive {
            print("isFilterering")
            user = filtredUsers[indexPath.row]
        } else {
            
            print("NOT isFilterering")
            user = usersToAdd[indexPath.row]
        }
        
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.userFirstName + " " + user.userSecondName
//        print(cell.textLabel?.text)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if searchController.isActive {
            usersToAdd.append(filtredUsers[indexPath.row])
            usersToAddName.append(filtredUsers[indexPath.row].username)
            usersToAddUuID.append(filtredUsers[indexPath.row].uuid)
            searchController.isActive = false
            tableView.reloadData()
        }
        
    }
}
