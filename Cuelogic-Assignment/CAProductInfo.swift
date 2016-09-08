//
//  CAProductInfo.swift
//  Cuelogic-Assignment
//
//  Created by  Roshani Mahajan on 07/09/16.
//  Copyright © 2016 Roshani Mahajan. All rights reserved.
//

import UIKit
import SwiftyJSON

class CAProductInfo: NSObject {

    lazy var ProductName = ""
    lazy var ProductImageURL = ""
    lazy var ProductPrice = ""
    lazy var ProductVendorName = ""
    lazy var ProductVendorAddress = ""
    lazy var PhoneNumber = ""
    
    override init() {
    }
    
    init(_ result: AnyObject) {
        super.init()
        let jsonResult = JSON(result)
        
        if let value = jsonResult["productname"].string {
            ProductName = value
        }
        if let value = jsonResult["price"].string {
            ProductPrice = value
        }
        if let value = jsonResult["vendorname"].string {
            ProductVendorName = value
        }
        if let value = jsonResult["vendoraddress"].string {
            ProductVendorAddress = value
        }
        if let value = jsonResult["productImg"].string {
            ProductImageURL = value
        }
        if let value = jsonResult["phoneNumber"].string {
            PhoneNumber = value
        }
    }
    
    init(name: String, price: String, vendorName: String, vendorAddress: String, imageURL: String, phone: String) {
        super.init()
        ProductName = name
        ProductPrice = price
        ProductImageURL = imageURL
        ProductVendorName = vendorName
        ProductVendorAddress = vendorAddress
        PhoneNumber = phone
    }
    
}
