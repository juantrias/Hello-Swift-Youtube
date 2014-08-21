//
//  YouTubeViewController.swift
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import UIKit

let reuseIdentifier = "YouTubeVideoCell"

class YouTubeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    var searchListJSONModel: YUSearchListJSONModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes (Mejor se asocia desde el Storyboard)
        //self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        // TODO remember the last search
        searchVideos("Google IO 2014")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchVideos(searchString: String) {
        YoutubeManager.sharedInstance.search(searchString
            , onSuccess: { (searchListJSONModel: YUSearchListJSONModel) in
                self.searchListJSONModel = searchListJSONModel
                self.collectionView.reloadData()
                println("YoutubeManager search onSuccess")  // \(self.searchListJSONModel)")
            }
            , onError: { (error: NSError) in
                // TODO alert view
        })
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

    /*func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        println("numberOfSectionsInCollectionView 1")
        return 1
    }*/

    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        if (searchListJSONModel != nil) {
            println("numberOfItemsInSection \(searchListJSONModel!.items.count)")
            return searchListJSONModel!.items.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as YouTubeCell
        
        // Configure the cell
        if (searchListJSONModel != nil) {
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
    
    // #pragma mark UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        println("textDidChange \(searchText)")
        if (countElements(searchText) >= 3) {
            let delay = 0.1 // seconds
            // TODO cancel previous search
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                self.searchVideos(searchText)
            })
        }
        
    }

}
