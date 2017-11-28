//
//  CountryNetworkImp.swift
//  CountrySearch
//
//  Created by Prabin K Datta on 28/11/17.
//  Copyright © 2017 Prabin K Datta. All rights reserved.
//

import Foundation
import SwiftyJSON

class CountryNetworkImp {
    func getCountryList(
        begin: (() -> Void)?,
        success: ((_ result: CountryResult<Country>) -> Void)?,
        error: ((_ statusCode: Int, _ errorResponse: ErrorResponse?) -> Void)?,
        complete: (() -> Void)?
        ){        
        
        Network.GET(uri: "/names.json",
                    parameters: nil,
                    authorization: "",
                    cacheEnabled: true,
                    begin: begin,
                    success: { (responseObject, headers) -> Void in
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                            guard let responseDictionary = responseObject as? NSDictionary else {
                                error?(410, nil)
                                return
                            }
                            
                            let json = JSON(responseDictionary)
                            let result = CountryResult<Country>()
                            for (code, name): (String, JSON) in json {
                                result.items += [Country.init(code: code, name: name.string!)]
                            }
                            success?(result)

                        }
                    },
                    error: { (lerror, statusCode, headers, responseObject) -> Void in
                        self.handleError(lerror: lerror, statusCode: statusCode, headers: headers, responseObject: responseObject, error: error)
                    },
                    complete: complete
        )
    }
    
    func handleError(
        lerror: Error,
        statusCode: Int,
        headers: [AnyHashable: Any]?,
        responseObject: AnyObject?,
        error: ((_ statusCode: Int,_ errorResponse: ErrorResponse?) -> Void)?) {
        if let responseDictionary = responseObject as? NSDictionary {
            let json = JSON(responseDictionary)
            let errorResponse = ErrorResponse(error: lerror, statusCode: statusCode, headers: headers, json: json)
            error?(statusCode, errorResponse)
        } else {
            let errorResponse = ErrorResponse(error: lerror, statusCode: statusCode, headers: headers, json: nil)
            error?(statusCode, errorResponse)
        }
    }
}
