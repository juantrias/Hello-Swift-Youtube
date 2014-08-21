//
//  YouTubeViewController.swift
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import UIKit

let reuseIdentifier = "YouTubeVideoCell"

class YouTubeViewController: UICollectionViewController {

    var searchListJSONModel: YUSearchListJSONModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes (Mejor se asocia desde el Storyboard)
        //self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        YoutubeManager.sharedInstance.search("Google IO 2014"
            , onSuccess: { (searchListJSONModel: YUSearchListJSONModel) in
                self.searchListJSONModel = searchListJSONModel
                self.collectionView.reloadData()
                println("YoutubeManager search onSuccess \(self.searchListJSONModel)")
            }
            , onError: { (error: NSError) in
                // TODO alert view
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */

    // #pragma mark UICollectionViewDataSource

    /*override func numberOfSectionsInCollectionView(collectionView: UICollectionView?) -> Int {
        return 1
    }*/

    override func collectionView(collectionView: UICollectionView?, numberOfItemsInSection section: Int) -> Int {
        if (searchListJSONModel) {
            return searchListJSONModel!.items.count
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView?, cellForItemAtIndexPath indexPath: NSIndexPath?) -> UICollectionViewCell? {
        let cell = collectionView?.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as YouTubeCell
    
        // Configure the cell
        if (searchListJSONModel) {
            let item: YUItemJSONModel = searchListJSONModel!.items[indexPath!.row] as YUItemJSONModel
            cell.titleLabel.text = item.snippet.title
            cell.thumbImageView.setImageWithURL(NSURL(string: item.snippet.thumbnails.defaultThumb.url))
            
        }
        
        return cell
    }

    // pragma mark <UICollectionViewDelegate>

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(collectionView: UICollectionView?, shouldHighlightItemAtIndexPath indexPath: NSIndexPath?) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView?, shouldSelectItemAtIndexPath indexPath: NSIndexPath?) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(collectionView: UICollectionView?, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath?) -> Bool {
        return false
    }

    func collectionView(collectionView: UICollectionView?, canPerformAction action: String?, forItemAtIndexPath indexPath: NSIndexPath?, withSender sender: AnyObject) -> Bool {
        return false
    }

    func collectionView(collectionView: UICollectionView?, performAction action: String?, forItemAtIndexPath indexPath: NSIndexPath?, withSender sender: AnyObject) {
    
    }
    */

}
