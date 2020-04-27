//
//  CoreDataFuncs.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 23.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit
import CoreData


func updateCoreData(data:  [Project]) {
    DispatchQueue.main.async {
        /// Delete all
        deleteAllFromCoreData()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
// MARK:- managedContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for project in data {
            let projectData = ProjectData(context: managedContext)
            
            projectData.projectId = Int16(project.projectID)
            projectData.projectName = project.projectName
            projectData.projectDescription = project.projectDescription
            projectData.projectCreationTime = Int64(project.projectCreationTime)
            projectData.projectExecutionTime = Int64(project.projectExecutionTime)
            
            let userData = userToUserData(project.projectOwner, managedContext)
//            let deadlineData = deadlineToDeadlineData(project.deadlines, managedContext)
            
            var projectUsersArray: [UserData] = []
            var deadlineArray: [DeadlineData] = []
            
            for projectUser in project.projectUsers ?? [] {
                let dataToAdd = userToUserData(projectUser, managedContext)
                projectUsersArray.append(dataToAdd)
            }
            for deadline in project.deadlines {
                deadlineArray.append(deadlineToDeadlineData(deadline, managedContext))
            }
            
        
            projectData.projectOwner = userData
            projectData.addToProjectUsers(NSSet(array: projectUsersArray ))
            projectData.addToProjectDeadlines(NSSet(array: deadlineArray ))

            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
    }
}

func userToUserData(_ user: User?, _ managedContext: NSManagedObjectContext) -> UserData{
    let userData = UserData(context: managedContext)
    userData.userId = Int16(user?.userID ?? 0)
    userData.userFirstName = user?.userFirstName
    userData.userSecondName = user?.userSecondName
    userData.username = user?.username
    userData.uuid = user?.uuid
    
    return userData
}

func deadlineToDeadlineData (_ deadline: Deadline?, _ managedContext: NSManagedObjectContext) -> DeadlineData {
    let deadlineData = DeadlineData(context: managedContext)
    deadlineData.deadlineId = Int16(deadline?.deadlineID ?? 0)
    deadlineData.deadlineName = deadline?.deadlineName
    deadlineData.deadlineDescription = deadline?.deadlineDescription
    deadlineData.deadlineProjectId = Int16(deadline?.deadlineProjectID ?? 0)
    deadlineData.deadlineCreationTime = Int64(deadline?.deadlineCreatedTime ?? 0)
    deadlineData.deadlineExecutionTime = Int64(deadline?.deadlineExecutionTime ?? 0)
    
    var deadlineUsersArray: [UserData]?
    
    for deadlineUser in deadline?.deadlineExecutors ?? [] {
        deadlineUsersArray?.append(userToUserData(deadlineUser, managedContext))
    }
    
    deadlineData.addToUser(NSSet(array: deadlineUsersArray ?? []))
    return deadlineData
}


// MARK:- fetchingCoreData
/// Function which fetch lesson from core data
func fetchingCoreData() -> [Project] {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return []}

    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectData")

    var projectsArray: [Project] = []
    do {
        /// All projects from Core Data
        guard let fetchResult = try managedContext.fetch(fetchRequest) as? [ProjectData] else { return [] }
        /// For each project
        for projectData in fetchResult {
            
            var projectUsersArray: [User] = []
            var projectDeadlineArray: [Deadline] = []
            /// All project users
            if let projectDataUserArray = projectData.projectUsers?.allObjects as? [UserData] {
                /// For each project user
                for projectDataUser in projectDataUserArray {
                   
                    let user = fetchOneUser(projectDataUser)
                    
                    projectUsersArray.append(user)
                }
            }
            /// All project deadlines
            if let projectDataDeadlineArray = projectData.projectDeadlines?.allObjects as? [DeadlineData] {
                /// For each project deadline
                for projectDataDeadline in projectDataDeadlineArray {
                   
                    var deadlineUsersArray: [User]?
                    
                    /// All deadline users
                    if let deadlineDataUserArray = projectDataDeadline.user?.allObjects as? [UserData] {
                        /// For each deadline user
                        for deadlineDataUser in deadlineDataUserArray {
                            let user = fetchOneUser(deadlineDataUser)
                            deadlineUsersArray?.append(user)
                        }
                    }
                    /// Fetch one deadline
                    let deadline = Deadline(deadlineID: Int(projectDataDeadline.deadlineId), deadlineName: projectDataDeadline.deadlineName ?? "", deadlineDescription: projectDataDeadline.deadlineDescription ?? "", deadlineProjectID: Int(projectDataDeadline.deadlineProjectId), deadlineExecutorsUUID: [], deadlineExecutors: deadlineUsersArray, deadlineCreatedTime: Int(projectDataDeadline.deadlineCreationTime), deadlineExecutionTime: Int(projectDataDeadline.deadlineExecutionTime))
                    
                    projectDeadlineArray.append(deadline)
                }
            }
            
            if let projectDataOwner = projectData.projectOwner {
                let projectOwner = fetchOneUser(projectDataOwner)
            
                let project = Project(projectID: Int(projectData.projectId), projectName: projectData.projectName ?? "", projectDescription: projectData.projectDescription ?? "", deadlines: projectDeadlineArray , projectOwner: projectOwner, projectUsers: projectUsersArray, projectOwnerUuid: projectOwner.uuid, projectUsersUuid: [], projectCreationTime: Int(projectData.projectCreationTime), projectExecutionTime: Int(projectData.projectExecutionTime))
                
                projectsArray.append(project)
            }

        }
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
    
    return projectsArray
}


func fetchOneUser(_ projectDataUser: UserData) -> User {
    
    let user = User(userID: Int(projectDataUser.userId), userFirstName: projectDataUser.userFirstName ?? "", userSecondName: projectDataUser.userSecondName ?? "", username: projectDataUser.username ?? "", uuid: projectDataUser.uuid ?? "", projectsCreated: [], projectsAppended: [], userCreationTime: Int(projectDataUser.userCreationTime))
    
    return user
}


// MARK:- deleteAllFromCoreData
///Function that clear Core Data
func deleteAllFromCoreData() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectData")

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

    // Configure Fetch Request
    fetchRequest.includesPropertyValues = false

    do {
        let managedContext = appDelegate.persistentContainer.viewContext

        let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]

        for item in items {
            managedContext.delete(item)
        }

        /// Save Changes
        try managedContext.save()

    } catch {
        print("Could not delete. \(error)")
    }
}
