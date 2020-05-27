//
//  DeadlinesManagerTests.swift
//  DeadlinesManagerTests
//
//  Created by Головаш Анастасия on 28.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//
@testable import DeadlinesManager
import XCTest

class DeadlinesManagerTests: XCTestCase {

    var exp: XCTestExpectation!
    
    override func setUp() {
        exp = expectation(description: "Get and parse all JSONs")
    }

    override func tearDown() {
        exp = nil
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /**
     Testing api getting all projects.
     */
    func testAPIAllProjects() throws {
        postAndGetData(URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/allProjects")!, httpMethod: "GET") { (data) in
            if let _ = try? JSONDecoder().decode([Project].self, from: data) {
                self.exp.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }
    
    /**
    Testing api adding and deleting project.
    */
    func testAPIDeleteProject() throws {
        
        let parameters = ["project": ["projectName" : "1", "projectDescription" : "1", "projectExecutionTime" : 10000000], "usersToAdd": ["ddanilyuk"] ] as [String : Any]

        //create the url with URL
        let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/createProject")! //change the url

        var projectID = 0
        
        postDataWithParameters(url, parameters) { (data) in

            if let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
            
            if let project = try? JSONDecoder().decode(Project.self, from: data) {
                projectID = project.projectID
                DispatchQueue.main.async {
                    self.testAPIAddingUser(projectID: projectID)
                    self.testApiDeleting(projectID: projectID)
                }
            }
        }
        
        self.waitForExpectations(timeout: 10)
    }
    
    /**
    Testing api deting project.
    */
    func testApiDeleting(projectID: Int) {
        postAndGetData(URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(projectID)/deleteProject")!, httpMethod: "DELETE") { (data) in
            if let answer = try? JSONDecoder().decode(Error.self, from: data) {
                if answer.message == "Deleted" {
                    self.exp.fulfill()
                }
            }
        }
    }
    
    /**
    Testing api adding and deleting project.
    */
    func testAPIAddingUser(projectID: Int) {
        
        let url = URL(string: "http://192.168.31.88:8080/\(Settings.shared.uuID)/\(projectID)/addUserToProject/NewUser")!
        postAndGetData(url, httpMethod: "POST") { data in
            if let project = try? JSONDecoder().decode(Project.self, from: data) {
                if project.projectUsersInvited?.count ?? 0 > 0 {
                    self.exp.fulfill()
                }
            }
        }        
    }
    
    /**
    Testing Core Data is not empty.
    */
    func testCoreDataIsNotEmpty() {
        let projectsFromCoredata = fetchingCoreData()
        if (projectsFromCoredata.count > 0) {
            self.exp.fulfill()
        }
        waitForExpectations(timeout: 10)

    }
    
    /**
    Testing Core Data adding data.
    */

    func testCoreDataAdd() {
        deleteAllFromCoreData()
        
        let project = Project(projectID: 1, projectName: "1", projectDescription: "1", deadlines: [], projectOwner: nil, projectUsers: [], projectUsersInvited: [], projectCreationTime: 1, projectExecutionTime: 1, completeMark: false)
        
        updateCoreData(data: [project]) {
            let projectsFromCoredata = fetchingCoreData()
            if (projectsFromCoredata.count == 1) {
                self.exp.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }
}
