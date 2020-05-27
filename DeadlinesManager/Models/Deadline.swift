//
//  Deadline.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 27.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit


struct Deadline: Codable {
    let deadlineID: Int
    let deadlineName, deadlineDescription: String
    let deadlineProjectID: Int
    let deadlineExecutors: [User]?
    let deadlineCreatedTime: Int
    let deadlineExecutionTime: Int
    let completeMark: Bool
    let completedBy: String
    

    enum CodingKeys: String, CodingKey {
        case deadlineID = "deadlineId"
        case deadlineProjectID = "deadlineProjectId"
        case deadlineName, deadlineDescription, deadlineCreatedTime, deadlineExecutionTime, deadlineExecutors, completeMark, completedBy

    }
}
