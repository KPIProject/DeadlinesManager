//
//  User.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 27.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit


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
