//
//  Error.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 27.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit


struct Error: Codable {
    let type: String
    let code: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case type, code, message
    }
}
