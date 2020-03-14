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
    let userFirstName, userSecondName, username, password: String
    let uuid: String
    let projects: [Project]

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userFirstName, userSecondName, username, password, uuid, projects
    }
}

// MARK: - Project
struct Project: Codable {
    let projectID: Int
    let projectName, projectDescription: String
    let userOwnerID: Int
    let deadlines: [Deadline]

    enum CodingKeys: String, CodingKey {
        case projectID = "projectId"
        case projectName, projectDescription, userOwnerID, deadlines
    }
}

// MARK: - Deadline
struct Deadline: Codable {
    let deadlineID: Int
    let deadlineName, deadlineDescription: String

    enum CodingKeys: String, CodingKey {
        case deadlineID = "deadlineId"
        case deadlineName, deadlineDescription
    }
}
