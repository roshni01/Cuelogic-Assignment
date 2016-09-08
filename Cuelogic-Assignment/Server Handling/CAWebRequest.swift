//
//  CAWebRequest.swift
//  Cuelogic-Assignment
//
//  Created by Roshani Mahajan on 07/09/16.
//  Copyright © 2016 Roshani Mahajan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let DEBUG_REQUEST: Bool = true
let DEBUG_RESPONSE: Bool = true

enum CAWebRequestMethodType {
    case GET
    case POST
}

class CAWebRequest: NSObject {
    
    class func Request(Url: NSURL, methodType: CAWebRequestMethodType = .GET, headers: [String: String]? = nil, params: [String: AnyObject]? = nil, complition: (result: AnyObject?) -> Void, failure: (error: NSError?) -> Void) {
        
        let req = NSMutableURLRequest(URL: Url)
        
        switch methodType {
        case .GET:
            req.HTTPMethod = "GET"
        case .POST:
            req.HTTPMethod = "POST"
        }
        
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        if let _headers = headers {
            for header in _headers {
                req.setValue(header.1, forHTTPHeaderField: header.0)
            }
        }
        
        if methodType != .GET {
            if let p = params {
                req.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(p, options: [])
            }
        }
        
        if DEBUG_REQUEST {
            print("Request Headers : \(req.allHTTPHeaderFields)")  // original URL request
            if let p = params {
                print("Request Params : \(JSON(p))\n")
            }
        }
        
        request(req).responseJSON { response in
            if DEBUG_RESPONSE {
                print("Response Headers : \(response.response)") // URL response
                
                print("Response Result : \(response.result)")   // result of response serialization (Success/Failure)
                
                //print("Response Data : \(response.data)")     // server data
                if let res = String.init(data: response.data!, encoding: NSUTF8StringEncoding) {
                    print("Response Result Data : \(res))")
                }
            }
            
            switch response.result {
            case .Success:
                if let res = response.result.value {
                    complition(result: res)
                }
            case .Failure(let error):
                if response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                    if let res = response.result.value {
                        complition(result: res)
                    }
                    else {
                        complition(result: [])
                    }
                }
                else {
                    if DEBUG_RESPONSE {
                        print("Error: \(error)")
                    }
                    failure(error: error)
                }
            }
        }
    }
    
    class func GET(url: String, headers: [String: String]? = nil,  params: [String: AnyObject]? = nil, complition: (result: AnyObject?) -> Void, failure: (error: NSError?) -> Void) {
        
        CAWebRequest.Request(NSURL(string: url)!, methodType: .GET, headers: headers, params: params, complition: complition, failure: failure)
    }
    
    class func POST(url: String, headers: [String: String]? = nil,  params: [String: AnyObject]? = nil, complition: (result: AnyObject?) -> Void, failure: (error: NSError?) -> Void) {
        
        CAWebRequest.Request(NSURL(string: url)!, methodType: .POST, headers: headers, params: params, complition: complition, failure: failure)
    }
    
}

