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
    let userFirstName, userSecondName, username, uuid: String
    let projectsCreated: [Project]
    let projectsAppended: [Project]

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userFirstName, userSecondName, username, uuid, projectsCreated, projectsAppended
    }
}

// MARK: - Deadline
struct Deadline: Codable {
    let deadlineID: Int
    let deadlineName, deadlineDescription: String
    let deadlineProjectID: Int
    let deadlineExecutorsUUID: [String]

    enum CodingKeys: String, CodingKey {
        case deadlineID = "deadlineId"
        case deadlineName, deadlineDescription
        case deadlineProjectID = "deadlineProjectId"
        case deadlineExecutorsUUID = "deadlineExecutorsUuid"
    }
}

// MARK: - Project
struct Project: Codable {
    let projectID: Int
    let projectName, projectDescription: String
    let deadlines: [Deadline]
    let projectOwner: User
    let projectUsers: [User]

    enum CodingKeys: String, CodingKey {
        case projectID = "projectId"
        case projectName, projectDescription, deadlines, projectOwner, projectUsers
    }
}

// MARK: - Error
struct Error: Codable {
    let errorType: String
    let code: Int
    let errorMessage: String

    enum CodingKeys: String, CodingKey {
        case errorType = "error_type"
        case code
        case errorMessage = "error_message"
    }
}
