//
//  SearchTableViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 03.04.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

protocol SearchTableViewControllerDelegate {
    /**
     Edit users in project (delete or add)
     - Parameters:
        - names: array with first and second name
        - usernames: array with usernames
     */
    func editUsersInProject(names: [String], usernames: [String])
}

class SearchTableViewController: UITableViewController, UITextFieldDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var delegate: SearchTableViewControllerDelegate?
    
    /// User`s first and second names (all list)
    public var usersToAddName: [String] = []
    /// User`s usernames (all list)
    public var usersToAddUsername: [String] = []
    /// User`s first and second names (all list)
    public var invitedName: [String] = []
    /// User`s usernames (all list)
    public var invitedUsername: [String] = []
    /// Title that shows in SearchTableViewController
    public var titleToShow = ""
    /// Hide Segment Control if true
    public var isHideSegmentControl = true
    /// Search Controller for searching users by usernames
    private let searchController = UISearchController(searchResultsController: nil)
    /// Array with filtered users
    private var filtredUsers: [User] = []
    /// True if search bar button was taped
    private var searchBarButtonWasTaped: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearch()
        if isHideSegmentControl {
            segmentControl.isHidden = true
        }
        self.title = titleToShow
    }
    
    /**
    Table View settings
    */
    private func setupTableView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /**
    Search settings
    */
    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Почніть вводити логін щоб додати"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    /**
     Gets data from server when search bar button was taped.
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarButtonWasTaped = true
        getDataFromServer()
    }
    
    /**
     Sends data to serser using URL and get returned data from server
     */
    func getDataFromServer() {
        
        let login = searchController.searchBar.text ?? ""
        
        if self.searchBarButtonWasTaped && login.contains(" "){
            
            self.present(self.noticeAlert(message: "Юзернейм не повинен містити пробілів"), animated: true, completion: nil)
            self.searchBarButtonWasTaped = false
            
        } else {
            guard let url = URL(string: "http://192.168.31.88:8080/findByUsername/\(login)") else { return }
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
    
    /**
     Reload data when Segment Control was taped.
     */
    @IBAction func didPressSegmentControl(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    /**
    Share data by delegate and dismiss VC  when Done was taped.
    */
    @IBAction func didPressDone(_ sender: UIBarButtonItem) {
        delegate?.editUsersInProject(names: usersToAddName, usernames: usersToAddUsername)
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension SearchTableViewController: UISearchResultsUpdating {
    /**
     Search func: updateSearchResults
    */
    func updateSearchResults(for searchController: UISearchController) {
        filtredUsers = []
        getDataFromServer()
        tableView.reloadData()
    }
    
}

extension SearchTableViewController {
    
    // MARK: - Table view data source
    
    /**
     TableView func: numberOfRowsInSection
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filtredUsers.count
        } else if segmentControl.selectedSegmentIndex == 1 {
            return invitedName.count
        } else {
            return usersToAddName.count
        }
        
    }
    
    /**
     TableView func: heightForRowAt
    */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }

    /**
     TableView func: cellForRowAt
    */
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
            switch segmentControl.selectedSegmentIndex {
            case 0:
                cell.textLabel?.text = usersToAddUsername[indexPath.row]
                cell.detailTextLabel?.text = usersToAddName[indexPath.row]
            case 1:
                cell.textLabel?.text = invitedUsername[indexPath.row]
                cell.detailTextLabel?.text = invitedName[indexPath.row]
            default:
                print("Error")
            }
            
        }
        
        return cell
    }
    
    /**
     TableView func: didSelectRowAt
    */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if searchController.isActive {
            let user = filtredUsers[indexPath.row]
            usersToAddName.append(user.userFirstName + " " + user.userSecondName)
            usersToAddUsername.append(user.username )
            searchController.isActive = false
            tableView.reloadData()
        }
        
    }
    
    /**
     TableView func: trailingSwipeActionsConfigurationForRowAt
    */
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if searchController.isActive || segmentControl.selectedSegmentIndex == 1 {
            tableView.isEditing = false
            return nil
        } else {
            let delete = UIContextualAction(style: .destructive, title: "Видалити") { (action, view, completion ) in
                self.usersToAddUsername.remove(at: indexPath.row)
                self.usersToAddName.remove(at: indexPath.row)
                tableView.reloadData()
                tableView.isEditing = false
            
            }
            let config = UISwipeActionsConfiguration(actions: [delete])
            return config
        }
    }
    
}
