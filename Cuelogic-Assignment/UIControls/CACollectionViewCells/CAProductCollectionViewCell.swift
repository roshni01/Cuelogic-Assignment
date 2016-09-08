//
//  CAProductCollectionViewCell.swift
//  Cuelogic-Assignment
//
//  Created by Roshani Mahajan on 07/09/16.
//  Copyright © 2016 Roshani Mahajan. All rights reserved.
//

import UIKit

@objc protocol CAProductCollectionViewCellDelegate {
    
    func onProductAddedToCart(sender: AnyObject)
}

class CAProductCollectionViewCell: UICollectionViewCell {
    
    var delegate: CAProductCollectionViewCellDelegate?

    @IBOutlet weak var addToCartBtn: UIButton!
    @IBOutlet weak var cartAddLabel: UILabel!
    @IBOutlet weak var vendorAddress: UILabel!
    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    
    //MARK: Action Methods
    
    @IBAction func cartBtnClicked(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.onProductAddedToCart(sender)
        }
    }
}
