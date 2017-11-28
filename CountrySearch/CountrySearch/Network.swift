//
//  Network.swift
//  CountrySearch
//
//  Created by Prabin K Datta on 27/11/17.
//  Copyright © 2017 Prabin K Datta. All rights reserved.
//

import Foundation
import AFNetworking

class Network {
    //    static var networkRequestOperation:  AFHTTPRequestOperationManager?
    static var ifModifiedSinceCache = [String : AnyObject]()
    static var parameterCache = [String : AnyObject]()
    
    enum `Type` {
        case JSON
        case HTML
        case DATA
    }
    
    struct Internal {
        
        static var baseUrl: String {
            get {
                let environment = Environment.instance()
                return environment.baseUrlWithContext
            }
        }
        
        static var allowsInvalidSSLCertificate: Bool {
            get {
//                let environment = Environment.instance()
                return true//environment.allowsInvalidSSLCertificate
            }
        }
        
    }
    
    class func GET(
        uri: String,
        parameters: NSDictionary?,
        authorization: String?,
        cacheEnabled: Bool,
        begin: (() -> Void)?,
        success: ((_ responseObject: Any?, _ headers: [AnyHashable : Any]?) -> Void)?,
        error: ((_ error: Error,_ statusCode: Int,_ headers: [AnyHashable : Any]?,_ responseObject: AnyObject?) -> Void)?,
        complete: (() -> Void)?) {

        // handle relative or absolute urls
        //let url = uri.rangeOfString(":") != nil ? uri : Internal.baseUrl + uri
        let url = uri.range(of: ":", options:.regularExpression) != nil ? uri : Internal.baseUrl + uri
        // invoke begin closure
        begin?()

        // configure manager
        let manager = configureManager(type: Type.JSON, authorization: authorization)
        // make network call

//        manager.requestSerializer.setValue(State.sessionUUID ?? "", forHTTPHeaderField: "SESSION_UUID")

        if cacheEnabled, let ifModifiedSince = ifModifiedSinceCache[url] as? String {
            if let parameters = parameters, let params = parameterCache[url] as? NSDictionary  {
                if parameters == params {
                    manager.requestSerializer.setValue(ifModifiedSince, forHTTPHeaderField: "If-Modified-Since")
                }
            } else {
                manager.requestSerializer.setValue(ifModifiedSince, forHTTPHeaderField: "If-Modified-Since")
            }
        }

        manager.get(url, parameters: parameters, progress:nil,

                    success: { (task: URLSessionDataTask!, responseObject: Any?) -> Void in

                        ifModifiedSinceCache[url] = (task.response as! HTTPURLResponse).allHeaderFields["Last-Modified"] as AnyObject
                        if let _ = ifModifiedSinceCache[url] as? String {
                            parameterCache[url] = parameters
                        }

                        print("allHeaderFields:\((task.response as! HTTPURLResponse).allHeaderFields)")
                        print("\((task.response as! HTTPURLResponse).statusCode) \(task.originalRequest?.httpMethod!) \(task.originalRequest?.url!.absoluteString)")
                        if parameters != nil {
                            print(parameters!)
                        }
                        if responseObject != nil {
                            //print(responseObject!)
                        }

                        // invoke success closure
                        success?(responseObject, (task.response as! HTTPURLResponse).allHeaderFields)

                        // invoke complete closure
                        complete?()

        },

                    failure: { (task: URLSessionDataTask!, e: Error!) -> Void in

                        print("\(task.response != nil ? (task.response as! HTTPURLResponse).statusCode : 0) \(task.originalRequest?.httpMethod!) \(task.originalRequest?.url!.absoluteString)")
                        if parameters != nil {
                            print(parameters!)
                        }

                        // log error
                        print("Error: \(e.localizedDescription)")

                        // invoke error closure
                        if task != nil && task.response != nil {
                            error?(e, (task.response as! HTTPURLResponse).statusCode, (task.response as! HTTPURLResponse).allHeaderFields, task.response)
                        }
                        else {
                            error?(e, 0, nil, nil)
                        }

                        // invoke complete closure
                        complete?()

        }

        )

    }
    
    class func configureManager(type: Type, authorization: String?) -> AFHTTPSessionManager {
        
        let manager = AFHTTPSessionManager()
        
        // disable ssl checking if required
        if Internal.allowsInvalidSSLCertificate {
            manager.securityPolicy.allowInvalidCertificates = true
        }
        
        // set tracking headers
        manager.requestSerializer.setValue(DeviceInfo.uuid, forHTTPHeaderField: "UUID")
        manager.requestSerializer.setValue(DeviceInfo.platform, forHTTPHeaderField: "PLATFORM")
        manager.requestSerializer.setValue(DeviceInfo.osVersion, forHTTPHeaderField: "OS_VERSION")
        manager.requestSerializer.setValue(DeviceInfo.appVersion, forHTTPHeaderField: "APP_VERSION")
        manager.requestSerializer.setValue(DeviceInfo.buildVersion, forHTTPHeaderField: "BUILD_VERSION")
        manager.requestSerializer.setValue(DeviceInfo.deviceType, forHTTPHeaderField: "DEVICE_TYPE")
        manager.requestSerializer.setValue(DeviceInfo.model, forHTTPHeaderField: "MODEL")
//        manager.requestSerializer.setValue(State.sessionUUID ?? "", forHTTPHeaderField: "SESSION_UUID")
        
        // set cache policy
        manager.requestSerializer.cachePolicy = .useProtocolCachePolicy
        
        // set timeout
        manager.requestSerializer.timeoutInterval = 90
        
        // set acceptable content types
        if type == Type.HTML {
            manager.responseSerializer = AFHTTPResponseSerializer()
        }
        else if type == Type.JSON {
            manager.responseSerializer.acceptableContentTypes = Set<String>(arrayLiteral: "application/hal+json", "application/problem+json", "application/json")
        }
        else if type == Type.DATA {
            manager.responseSerializer = AFHTTPResponseSerializer()
        }
        
        // remove all cookies
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies
        if cookies != nil {
            for cookie in cookies! {
                cookieStorage.deleteCookie(cookie )
            }
        }
        
        // set authorization
        if authorization != nil {
            
            // println("Access token: \(authorization!)")
            
            // oAuth style
            // manager.requestSerializer.setValue("Bearer " + authorization!, forHTTPHeaderField: "Authorization")
            
            // compute domain no port
            //let environment = Environment.instance()
//            var domainParts = environment.domain.split(":")
//            let domainNoPort = domainParts[0]
//
//            // data power style
//            let cookie = NSHTTPCookie(properties: [
//                NSHTTPCookieDomain: domainNoPort,
//                NSHTTPCookiePath: "/",
//                NSHTTPCookieName: "X-Auth-Token",
//                NSHTTPCookieValue: authorization!
//                ]
//            )
//            cookieStorage.setCookie(cookie!)
            
        }
        else {
            
        }
        
        return manager
        
    }
}
