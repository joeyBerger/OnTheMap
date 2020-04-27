//
//  LoginInfo.swift
//  PinSample
//
//  Created by Joey Berger on 4/11/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct LoginInfo: Codable {
    let userInfo: UserInfo
    enum CodingKeys: String, CodingKey {
        case userInfo = "account"
    }
}

struct UserInfo: Codable {

    let registered: Bool
    let key: String
    
    enum CodingKeys: String, CodingKey {
        case registered
        case key
    }
}

struct ErrorInfo: Codable {
    let status: Int
    let error: String
       
    enum CodingKeys: String, CodingKey {
       case status
       case error
    }
}
