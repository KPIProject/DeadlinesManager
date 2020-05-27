//
//  Project.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 27.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit


struct Project: Codable {
    let projectID: Int
    let projectName, projectDescription: String
    let deadlines: [Deadline]
    let projectOwner: User?
    let projectUsers: [User]?
    let projectUsersInvited: [User]?
    let projectCreationTime: Int
    let projectExecutionTime: Int
    let completeMark: Bool

    enum CodingKeys: String, CodingKey {
        case projectID = "projectId"
        case projectName, projectDescription, deadlines, projectOwner, projectUsers, projectCreationTime, projectExecutionTime, projectUsersInvited, completeMark
    }
}
