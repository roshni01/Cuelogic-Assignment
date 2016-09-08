//
//  CACartViewController.swift
//  Cuelogic-Assignment
//
//  Created by  Roshani Mahajan on 07/09/16.
//  Copyright © 2016 Roshani Mahajan. All rights reserved.
//

import UIKit

@objc protocol CAModifyArrayDelegate {
    func modifyCartArray(products: Array<CAProductInfo>, product: CAProductInfo)
}

class CACartViewController: UIViewController {

    var delegate: CAModifyArrayDelegate?

    @IBOutlet weak var bottomPriceView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var Products = Array<CAProductInfo>()

    var session: NSURLSession?
    var task: NSURLSessionDownloadTask?
    var cache: NSCache?
    
    //MARK: View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = NSURLSession.sharedSession()
        task = NSURLSessionDownloadTask()
        cache = NSCache()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if Products.count == 0 {
            messageLabel.hidden = false
            bottomPriceView.hidden = true
        }
        else {
            messageLabel.hidden = true
            bottomPriceView.hidden = false
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: IBAction Methods
    
    @IBAction func removeCartClicked(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! CACartTableViewCell
        
        let indexPath = tableView.indexPathForCell(cell)
        
        if let delegate = delegate {
            let product = Products.removeAtIndex((indexPath?.row)!)

            delegate.modifyCartArray(self.Products, product: product)
        }

        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.setTotalPrice()

    }
    
    @IBAction func callVendorClicked(sender: AnyObject) {
        let product = self.Products[sender.tag]
        let phoneNumber = product.PhoneNumber
        self.callNumber(phoneNumber)

        
    }
    
    //MARK: Utility Methods
    
    func setTotalPrice() {
        var totalPrice: Double = 0

        for product in self.Products {
            totalPrice  += Double(product.ProductPrice)!
        }
        totalPriceLabel.text = "Total Price: " + String(totalPrice)
    }

    //MARK: Calling Methods
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }

}

//MARK: TableView DataSource Methods

extension CACartViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Products.count != 0 {
            return Products.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "CartCell"
        
        let cell : CACartTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! CACartTableViewCell
        cell.removeCartBtn.tag = indexPath.row
        
        let product : CAProductInfo = self.Products[indexPath.row]
        cell.cartProductName.text = product.ProductName
        cell.cartVendorName.text = product.ProductVendorName
        cell.cartVendorAddress.text = product.ProductVendorAddress
        cell.cartPrice.text = product.ProductPrice
        self.setTotalPrice()
        
        
        if (self.cache!.objectForKey(indexPath.row) != nil) {
            cell.cartImageView?.image = self.cache?.objectForKey(indexPath.row) as? UIImage
        } else {
            let productImageURL = product.ProductImageURL
            let url = NSURL(string: productImageURL)
            
            if (self.cache!.objectForKey(indexPath.row) != nil) {
                cell.cartImageView?.image = self.cache?.objectForKey(indexPath.row) as? UIImage
            } else {
                task = session!.downloadTaskWithURL(url!, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
                    
                    if let data = NSData(contentsOfURL: url!) {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            if let updateCell = self.tableView.cellForRowAtIndexPath(indexPath) {
                                let  updatedCell = updateCell as! CACartTableViewCell
                                let image : UIImage = UIImage(data: data)!
                                updatedCell.cartImageView.image = image
                                self.cache?.setObject(image, forKey: indexPath.row)
                            }
                            
                        })
                    }
                })
                task?.resume()
            }
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }

}
