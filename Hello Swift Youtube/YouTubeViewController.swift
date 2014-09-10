//
//  YouTubeViewController.swift
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import UIKit

let reuseIdentifier = "YouTubeVideoCell"

class YouTubeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, YoutubeManagerDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    var youtubeManager: YoutubeManager? = nil
    var reloadAllVideos = true // Reload the entire Collection View the next time dataProvider.didLoadDataAtIndexes() is called
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes (Mejor se asocia desde el Storyboard)
        //self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        self.youtubeManager = YoutubeManager(delegate: self)
        
        println("Realm video count \(VideoDto.allObjects().count)")
        
        let lastSearchString = NSUserDefaults.standardUserDefaults().stringForKey(SP_KEY_LAST_SEARCH_STRING)
        if (lastSearchString != nil) {
            searchBar.text = lastSearchString
            searchVideos(lastSearchString!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private methods

    func searchVideos(searchString: String) {
        
        NSUserDefaults.standardUserDefaults().setObject(searchString, forKey: SP_KEY_LAST_SEARCH_STRING)
        
        if (self.collectionView.numberOfItemsInSection(0) > 0) {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
        
        self.youtubeManager?.search(searchString, onSuccess: { (videos) -> Void in
            
            //self.collectionView.reloadData()
            self.reloadAllVideos = true
            println("Search onSuccess")
            
        }, onError: { (error) -> Void in
            let alertView = ErrorUIHelper.alertViewForError(error)
            alertView.show()
        })
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        let videoVC: VideoViewController = segue.destinationViewController as VideoViewController
        var indexPath: NSIndexPath = self.collectionView.indexPathsForSelectedItems()[0] as NSIndexPath
        videoVC.videoDto = youtubeManager!.searchResultsVideoAtIndex(UInt(indexPath.row))
    }
    
    // MARK: - UICollectionViewDataSource

    /*func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        println("numberOfSectionsInCollectionView 1")
        return 1
    }*/

    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        if (youtubeManager != nil) {
            let searchResultsCount = youtubeManager!.searchResultsCount()
            println("numberOfItemsInSection \(searchResultsCount)")
            return searchResultsCount
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as YouTubeCell
        
        // Configure the cell
        if (youtubeManager != nil) {
            let dataObject: AnyObject? = youtubeManager!.searchResultsVideoAtIndex(UInt(indexPath.row))
            if (dataObject == nil) {
                cell.titleLabel.text = nil
                cell.thumbImageView.image = UIImage(named: "icon_video")
            } else {
                let videoDto = dataObject as VideoDto
                cell.titleLabel.text = videoDto.title
                cell.thumbImageView.setImageWithURL(NSURL(string: videoDto.thumbnail))
            }
        }
        
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
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
    
    // MARK: - YoutubeManagerDelegate
    
    func manager(manager: YoutubeManager, didLoadDataAtIndexes indexes: NSIndexSet) {
        
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems() as [NSIndexPath] // ATT: the  contains function requires this casting to [NSIndexPath]
        
        // If no visible cells (ie first load) reload all the collectionView. In other case reload only the visible cells
        if (self.reloadAllVideos || visibleIndexPaths.count == 0) {
            self.collectionView.reloadData()
            self.reloadAllVideos = false
        
        } else {
            var indexPathsToReload = [NSIndexPath]()
            indexes.enumerateIndexesUsingBlock { (idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                
                let indexPath = NSIndexPath(forRow: idx, inSection: 0)
                if (contains(visibleIndexPaths, indexPath)) {
                    indexPathsToReload.append(indexPath)
                }
            }
            
            if (indexPathsToReload.count > 0) {
                self.collectionView.reloadItemsAtIndexPaths(indexPathsToReload)
            }
        }
    }
    
    func manager(manager: YoutubeManager, errorLoadingDataAtIndexes indexes: NSIndexSet, error: NSError) {
        let alertView = ErrorUIHelper.alertViewForError(error)
        alertView.show()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        //println("textDidChange \(searchText)")
        if (countElements(searchText) >= 3) {
            let delay = 0.1 // seconds
            // TODO cancel previous search
            /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                self.searchVideos(searchText)
            })*/
        }
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        println("search \(searchBar.text)")
        self.searchVideos(searchBar.text)
    }

}
