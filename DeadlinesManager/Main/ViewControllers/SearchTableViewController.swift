//
//  SearchTableViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 03.04.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {

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
        searchController.searchBar.placeholder = "Почніть вводити логін"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filtredUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let user = filtredUsers[indexPath.row]
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.userFirstName + " " + user.userSecondName
//        print(cell.textLabel?.text)
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// Sends data to serser using URL and get returned data from server
    func getDataFromServer(_ url: URL) {
        //create the session object
        let session = URLSession.shared

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            if let data = data {
                if let error = try? JSONDecoder().decode(Error.self, from: data) {
                    switch error.errorMessage {
                    case "Users not found":
                        DispatchQueue.main.async {
                            self.present(self.noticeAlert(message: "Юзерів з даним логіном немає"), animated: true, completion: nil)
                        }
                    default:
                        break
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

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        print(®searchController.searchBar.text ?? "NOTHING")
//        print("http://localhost:8080/findByUsername/\(searchController.searchBar.text ?? "")")
        filtredUsers = []
        let url = URL(string: "http://localhost:8080/findByUsername/\(searchController.searchBar.text ?? "")")!
        getDataFromServer(url)
    }
    
//    private func filterContentForSearchText(_ searchText)
    
}
