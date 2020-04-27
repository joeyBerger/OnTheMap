//
//  UdacityClient.swift
//  PinSample
//
//  Created by Joey Berger on 4/11/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class UdacityClient {
    
    struct Auth {
        static var uniqueKey = ""
        static var lastName = ""
        static var firstName = ""
    }

    class func postSession(username: String, password: String, completion: @escaping (String, Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            var inputObj: [String: [String: String]] = ["":[:]]
            inputObj["udacity"] = ["username": "\(username)", "password": "\(password)"]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: inputObj)
            } catch let error {
                print(error.localizedDescription)
            }
        
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
              if error != nil {
                  completion("", error)
                  return
              }
              let range = (5..<data!.count)
              let newData = data?.subdata(in: range) /* subset response data! */
              print(String(data: newData!, encoding: .utf8)!)
                let decoder = JSONDecoder()
                do {
                    //see if able to parse JSON into LoginInfo struct
                    let responseObject = try decoder.decode(LoginInfo.self, from: newData!)
                    Auth.uniqueKey = responseObject.userInfo.key
                    DispatchQueue.main.async {
                        completion("success",nil)
                    }
                    
                } catch {
                    //see if able to parse JSON into ErrorInfo struct
                    do {
                        _ = try decoder.decode(ErrorInfo.self, from: newData!)
                        DispatchQueue.main.async {
                            completion("fail",nil)
                        }
                    } catch {
                        print("something went wrong with login")
                    }
                }
            }
            task.resume()
        }
    
    class func getStudentData(completion: @escaping (StudentResults?, Error?) -> Void) {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt&limit=100")!)
           let session = URLSession.shared
           let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
//            print(String(data: data!, encoding: .utf8)!)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(StudentResults.self, from: data!)
                DispatchQueue.main.async {
                    completion(responseObject,nil)
                }
            } catch {
                DispatchQueue.main.async {
                   completion(nil,nil)
               }
            }
        }
           task.resume()
    }
    
    class func deleteSession() {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil {
              return
          }
          let range = (5..<data!.count)
          let newData = data?.subdata(in: range)
          print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    class func getUserData() {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\(Auth.uniqueKey)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
              print("error in getting user data")
              return
            }
            let range = (5..<data!.count)
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
                
            //parse first and last names, save to auth struct
            let jsonOptional: AnyObject! = try! JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as AnyObject
            if let json = jsonOptional as? Dictionary<String, AnyObject> {
                if let lastName = json["last_name"] as AnyObject? as? String {
                    Auth.lastName = lastName
                }
                if let firstName = json["first_name"] as AnyObject? as? String {
                    Auth.firstName = firstName
                }
            }
        }
        task.resume()
    }
    
    class func postLocation(_ pinInfo: NewPinInfo, completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var inputObj: [String: Any] = [:]
        inputObj = ["uniqueKey": "\(Auth.uniqueKey)", "firstName": "\(Auth.firstName)", "lastName": "\(Auth.lastName)", "mapString": "\(pinInfo.mapString)", "mediaURL": "\(pinInfo.mediaURL)", "latitude": pinInfo.latitude, "longitude": (pinInfo.longitude)]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: inputObj)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil { // Handle error…
            DispatchQueue.main.async {
                completion(false,error)
            }
              
              return
          }
          print(String(data: data!, encoding: .utf8)!)
            let jsonOptional: AnyObject! = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as AnyObject
            
            var success = false
            if let json = jsonOptional as? Dictionary<String, AnyObject> {
                if (json["createdAt"] as AnyObject? as? String) != nil {
                    success = true
                }
            }
            DispatchQueue.main.async {
                completion(success,nil)
            }
        }
        task.resume()
    }
}
