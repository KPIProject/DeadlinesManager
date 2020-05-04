//
//  Struct.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 14.03.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import Foundation

// MARK: - User
struct User: Codable {
    let userID: Int
    let userFirstName, userSecondName, username: String
    let uuid: String?
    let projectsCreated: [Project]?
    let projectsAppended: [Project]?
    let userCreationTime: Int

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userFirstName, userSecondName, username, uuid, projectsCreated, projectsAppended, userCreationTime
    }
}

// MARK: - Deadline
struct Deadline: Codable {
    let deadlineID: Int
    let deadlineName, deadlineDescription: String
    let deadlineProjectID: Int
//    let deadlineExecutorsUUID: [String]?
    let deadlineExecutors: [User]?
    let deadlineCreatedTime: Int
    let deadlineExecutionTime: Int

    enum CodingKeys: String, CodingKey {
        case deadlineID = "deadlineId"
        case deadlineName, deadlineDescription, deadlineCreatedTime, deadlineExecutionTime, deadlineExecutors
        case deadlineProjectID = "deadlineProjectId"
//        case deadlineExecutorsUUID = "deadlineExecutorsUuid"
    }
}

// MARK: - Project
struct Project: Codable {
    let projectID: Int
    let projectName, projectDescription: String
    let deadlines: [Deadline]
    let projectOwner: User?
    let projectUsers: [User]?
    let projectUsersInvited: [User]?
//    let projectOwnerUuid: String?
//    let projectUsersUuid: [String]?
    let projectCreationTime: Int
    let projectExecutionTime: Int

    enum CodingKeys: String, CodingKey {
        case projectID = "projectId"
        case projectName, projectDescription, deadlines, projectOwner, projectUsers, projectCreationTime, projectExecutionTime, projectUsersInvited
    }
}

// MARK: - Error
struct Error: Codable {
    let type: String
    let code: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case type, code, message
    }
}
