//
//  StudentInformation.swift
//  PinSample
//
//  Created by Joey Berger on 4/11/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class StudentInfo {
    static var studentInfo = [StudentInformation]()
}

struct StudentResults: Codable {
    let studentInfo: [StudentInformation]
    enum CodingKeys: String, CodingKey {
        case studentInfo = "results"
    }
}

struct StudentInformation: Codable {
    let createdAt : String
    let firstName : String
    let lastName : String
    let latitude : Double
    let longitude : Double
    let mapString : String
    let mediaURL : String
    let objectId : String
    let uniqueKey : String
    let updatedAt : String
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case firstName
        case lastName
        case latitude
        case longitude
        case mapString
        case mediaURL
        case objectId
        case uniqueKey
        case updatedAt
    }
}
