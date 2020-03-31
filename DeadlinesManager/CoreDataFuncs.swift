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
            
            let userData = userToUserData(project.projectOwner, managedContext)
            
            var projectUsersArray: [UserData]?
            
            for projectUser in project.projectUsers ?? [] {
                projectUsersArray?.append(userToUserData(projectUser, managedContext))
            }
        
            projectData.projectOwner = userData
            projectData.addToProjectUsers(NSSet(array: projectUsersArray ?? []))
            

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

// MARK:- fetchingCoreData
/// Function which fetch lesson from core data
func fetchingCoreData() -> [Project] {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return []}

    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectData")

    var projectsArray: [Project] = []
    do {
        guard let fetchResult = try managedContext.fetch(fetchRequest) as? [ProjectData] else { return [] }

        for projectData in fetchResult {
            
            var projectUsersArray: [User]?
            
            if let projectDataUserArray = projectData.projectUsers?.allObjects as? [User] {
                
                for projectDataUser in projectDataUserArray {
                   
                    let user = User(userID: projectDataUser.userID, userFirstName: projectDataUser.userFirstName, userSecondName: projectDataUser.userSecondName, username: projectDataUser.username, uuid: projectDataUser.uuid, projectsCreated: [], projectsAppended: [], userCreationTime: projectDataUser.userCreationTime)
                    
                    projectUsersArray?.append(user)
                }
            }
            
            if let projectDataOwner = projectData.projectOwner {

                let projectOwner = User(userID: Int(projectDataOwner.userId ), userFirstName: projectDataOwner.userFirstName ?? "", userSecondName: projectDataOwner.userSecondName ?? "", username: projectDataOwner.username ?? "", uuid: projectDataOwner.uuid ?? "", projectsCreated: [], projectsAppended: [], userCreationTime: Int(projectDataOwner.userCreationTime))
            
                let project = Project(projectID: Int(projectData.projectId), projectName: projectData.projectName ?? "", projectDescription: projectData.projectDescription ?? "", deadlines: [], projectOwner: projectOwner, projectUsers: projectUsersArray, projectOwnerUuid: projectOwner.uuid, projectUsersUuid: [])
                
                projectsArray.append(project)
            }

        }
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
    
    return projectsArray
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
