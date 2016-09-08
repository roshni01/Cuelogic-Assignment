//
//  CACartTableViewCell.swift
//  Cuelogic-Assignment
//
//  Created by Roshani Mahajan on 07/09/16.
//  Copyright © 2016 Roshani Mahajan. All rights reserved.
//

import UIKit

class CACartTableViewCell: UITableViewCell {
    @IBOutlet weak var cartVendorAddress: UILabel!
    @IBOutlet weak var cartVendorName: UILabel!
    @IBOutlet weak var cartProductName: UILabel!
    @IBOutlet weak var cartPrice: UILabel!
    @IBOutlet weak var cartImageView: UIImageView!
    @IBOutlet weak var removeCartBtn: UIButton!
}
