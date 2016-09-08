//
//  CAShopViewController.swift
//  Cuelogic-Assignment
//
//  Created by Roshani Mahajan on 07/09/16.
//  Copyright © 2016 Roshani Mahajan. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD


let apiUrl = "https://mobiletest-hackathon.herokuapp.com/getdata/"

class CAShopViewController: UIViewController  {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var Products = Array<CAProductInfo>()
    var CartProducts = Array<CAProductInfo>()

    var session: NSURLSession?
    var task: NSURLSessionDownloadTask?
    var cache: NSCache?

    //MARK: View Liecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = NSURLSession.sharedSession()
        task = NSURLSessionDownloadTask()
        cache = NSCache()
        self.tabBarController?.delegate = self
        
        self.initFlowLayout()
        self.fetchData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initFlowLayout() {
        collectionView.backgroundColor = UIColor.whiteColor()

        let productListFlowLayout = UICollectionViewFlowLayout()
        productListFlowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical

        productListFlowLayout.itemSize = CGSizeMake(collectionView.frame.size.width/2 - 20, 237)

        productListFlowLayout.minimumInteritemSpacing = 5.0
        productListFlowLayout.minimumLineSpacing = 5.0
        productListFlowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.collectionView.collectionViewLayout = productListFlowLayout
        self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentOffset.y)
        self.collectionView.reloadData()
    }
    
    //MARK: Fetch and process Data from server
    func fetchData() {
        self.showLoader()
        CAWebRequest.GET(apiUrl, headers: nil,
                         complition: { (result) -> Void in
                            if let responseResult = result {
                                self.dismissLoader()
                                self.processData(responseResult)
                            }
        }) { (error) -> Void in
            var errorCode = 0
            if let err = error {
                errorCode = err.code
            }
            self.dismissLoader()
            print("Error code:\(errorCode)")
        }
    }
    
    func processData(result : AnyObject) {
        let jsonResult = JSON(result)
        if let products = jsonResult["products"].arrayObject {
            for product in products {
                
                let productInfo = CAProductInfo(product)
                Products.append(productInfo)
            }
            self.collectionView.reloadData()
        }
    }
    
    //MARK: SVProgressHUD Methods
    
    func showLoader() {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.None)
        SVProgressHUD.showWithStatus("Loading")
    }
    
    func dismissLoader() {
        SVProgressHUD.dismiss()
    }
    
    
    //MARK: Alert Display Method
    
    func displayAlert() {
            let alert = UIAlertController(title: "Success", message: "The product has been added to the cart!!!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}

//MARK: TabbarController Delegate Methods

extension CAShopViewController : UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if tabBarController.tabBar.selectedItem?.title == "Cart" {
            if viewController.isKindOfClass(UINavigationController){
                let navigationVC: UINavigationController = viewController as! UINavigationController
                let vcArray = navigationVC.viewControllers
                let vc = vcArray.last as! CACartViewController
                vc.Products = self.CartProducts
                vc.delegate = self
            }
        }
        
        return true
    }
}

//MARK: CollectionView DataSource Methods

extension CAShopViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if Products.count != 0 {
            return Products.count
        }
        return 0
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "ProductCell"
        
        let cell: CAProductCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CAProductCollectionViewCell
        let productInfo: CAProductInfo = self.Products[indexPath.row]
        
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 1.0
        
        cell.tag = indexPath.row
        cell.delegate = self
        cell.productName.text = productInfo.ProductName
        cell.productPrice.text = "Price: " + productInfo.ProductPrice
        cell.vendorName.text = productInfo.ProductVendorName
        cell.vendorAddress.text = productInfo.ProductVendorAddress
        
        
        if (self.cache!.objectForKey(indexPath.row) != nil) {
            cell.productImageView?.image = self.cache?.objectForKey(indexPath.row) as? UIImage
        }else {
            let productImageURL = productInfo.ProductImageURL
            let url = NSURL(string: productImageURL)
            
            
            if (self.cache!.objectForKey(indexPath.row) != nil) {
                cell.productImageView?.image = self.cache?.objectForKey(indexPath.row) as? UIImage
            } else {
                task = session!.downloadTaskWithURL(url!, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
                    
                    if let data = NSData(contentsOfURL: url!) {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            if let updateCell = self.collectionView.cellForItemAtIndexPath(indexPath) {
                                let  updatedCell = updateCell as! CAProductCollectionViewCell
                                let image : UIImage = UIImage(data: data)!
                                updatedCell.productImageView.image = image
                                self.cache?.setObject(image, forKey: indexPath.row)
                            }
                            
                            
                        })
                    }
                })
                task?.resume()
            }
        }
        return cell
    }
}

//MARK: <CAProductCollectionViewCellDelegate> Delegate Implementation

extension CAShopViewController : CAProductCollectionViewCellDelegate {
    
    func onProductAddedToCart(sender: AnyObject) {
        let button = sender as! UIButton

        let view = button.superview!
        let cell = view.superview as! CAProductCollectionViewCell
        cell.addToCartBtn.hidden = true
        cell.cartAddLabel.hidden = false
        let indexPath = collectionView.indexPathForCell(cell)
        
        self.CartProducts.append(self.Products[(indexPath?.row)!])
        
        self.displayAlert()
    }

}

//MARK: <CAModifyArrayDelegate> Delegate Implementation

extension CAShopViewController : CAModifyArrayDelegate {
    func modifyCartArray(products: Array<CAProductInfo>, product: CAProductInfo) {
        self.CartProducts = products
        
        for productInCollectionView in self.Products {
            if productInCollectionView == product {
                let index = self.Products.indexOf{$0 === product}
                let indexPath = NSIndexPath(forRow: index!, inSection: 0)
                let cell = collectionView!.cellForItemAtIndexPath(indexPath) as? CAProductCollectionViewCell
            
                cell?.addToCartBtn.hidden = false
                cell?.cartAddLabel.hidden = true

            }
        }
        
    }
    
}
