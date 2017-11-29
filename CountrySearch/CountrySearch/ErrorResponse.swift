//
//  ErrorResponse.swift
//  CountrySearch
//
//  Created by Prabin K Datta on 24/11/17.
//  Copyright © 2017 Prabin K Datta. All rights reserved.
//

import Foundation
import SwiftyJSON

class ErrorResponse {
    
    var error: Error?
    var statusCode: Int!
    var headers: [AnyHashable: Any]?
    var type: String?
    var title: String?
    var message: String?
    var fieldErrors = [FieldError]()
    
    init(error: Error?, statusCode: Int!, headers: [AnyHashable: Any]?, json: JSON?) {
        self.error = error
        self.statusCode = statusCode
        self.headers = headers
        if json != nil {
            self.type = json!["type"].string
            self.title = json!["title"].string
            self.message = json!["message"].string
            for (_, element): (String, JSON) in json!["fieldErrors"] {
                fieldErrors += [FieldError(json: element)]
            }
        }
        else if headers != nil {
            let authenticate = headers!["WWW-Authenticate"] as! String?
            if authenticate != nil {
                type = "UNAUTHORIZED"
                var authenticateTokens = authenticate!.components(separatedBy: "error_description=\"")
                message = authenticateTokens[authenticateTokens.count - 1]
                if message != nil {
                    message = message?.replacingOccurrences(of: "\"", with: "", options: String.CompareOptions.literal, range: nil)
                }
            }
        }
    }
    
}

class FieldError {
    
    var path: String!
    var key: String!
    var type: String!
    var message: String?
    
    init(json: JSON) {
        self.path = json["path"].string!
        self.key = json["key"].string!
        self.type = json["type"].string!
        self.message = json["message"].string
    }
    
    func messageWithDefault(defaultMessage: String!) -> String {
        if message == nil || (message!).characters.count == 0 {
            return defaultMessage
        }
        return message!
    }
    
}
