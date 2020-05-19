//
//  ServerManager.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 05.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

/// Sends data to serser using URL and get returned data from server
func postAndGetData(_ url: URL, httpMethod: String, complition: @escaping (Data) -> ()) {
    // create the session object
    let session = URLSession.shared

    // now create the URLRequest object using the url object
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
        guard error == nil else {
            return
        }
        if let data = data {
            complition(data)
        }
    })
    task.resume()
}

/// Sends data to serser using URL and get returned data from server
func postDataWithParameters(_ url: URL, _ parameters: [String : Any], complition: @escaping (Data) -> ()) {
    //create the session object
    let session = URLSession.shared

    //now create the URLRequest object using the url object
    var request = URLRequest(url: url)
    request.httpMethod = "POST" //set http method as POST

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
    } catch let error {
        print(error.localizedDescription)
    }

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    //create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

        guard error == nil else {
            return
        }

        if let data = data {
            complition(data)
        }
    })
    task.resume()
}
