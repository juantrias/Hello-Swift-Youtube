//
//  YouTubeViewController.swift
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import UIKit

let reuseIdentifier = "YouTubeVideoCell"

class YouTubeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, YoutubeSearchDataProviderDelegate {

    let SP_KEY_LAST_SEARCH_STRING = "last-search-string"
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    var youtubeSearchDataProvider: YoutubeSearchDataProvider? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes (Mejor se asocia desde el Storyboard)
        //self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
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

    func searchVideos(searchString: String) {
        
        NSUserDefaults.standardUserDefaults().setObject(searchString, forKey: SP_KEY_LAST_SEARCH_STRING)
        
        // La primera llamada al YoutubeManager la hace el VC, cuando recibe la respuesta con el total de resultados instancia el YoutubeSearchDataProvider con el dataCount, que a su vez inicializa el AWPagedArray que requiere un dataCount
        
        YoutubeManager.sharedInstance.search(searchString, pageToken: nil
            , onSuccess: { (searchListJSONModel: YUSearchListJSONModel) in
               
                // TODO instanciar un DataProvider cada vez que hago una busqueda?
                self.youtubeSearchDataProvider = YoutubeSearchDataProvider(searchString: searchString, dataCount: searchListJSONModel.pageInfo.totalResults, initialObjects: searchListJSONModel.items, nextPageToken:searchListJSONModel.nextPageToken, delegate: self)
                
                self.collectionView.reloadData()
                
                println("YoutubeManager search onSuccess")  // \(self.searchListJSONModel)")
            }
            , onError: { (error: NSError) in
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
        videoVC.itemJSONModel = youtubeSearchDataProvider!.dataObjects.objectAtIndex(UInt(indexPath.row)) as YUItemJSONModel
    }
    
    // MARK: - UICollectionViewDataSource

    /*func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        println("numberOfSectionsInCollectionView 1")
        return 1
    }*/

    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        if (youtubeSearchDataProvider != nil) {
            return Int(youtubeSearchDataProvider!.dataObjects.count())
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as YouTubeCell
        
        // Configure the cell
        if (youtubeSearchDataProvider != nil) {
            let dataObject: AnyObject! = youtubeSearchDataProvider!.dataObjects.objectAtIndex(UInt(indexPath.row))
            if (dataObject.isKindOfClass(NSNull.classForCoder())) {
                cell.titleLabel.text = nil
                cell.thumbImageView.image = UIImage(named: "icon_video")
            } else {
                let item = dataObject as YUItemJSONModel
                cell.titleLabel.text = item.snippet.title
                cell.thumbImageView.setImageWithURL(NSURL(string: item.snippet.thumbnails.defaultThumb.url))
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
    
    // MARK: - YoutubeSearchDataProviderDelegate
    
    func dataProvider(dataProvider: YoutubeSearchDataProvider, didLoadDataAtIndexes indexes: NSIndexSet) {
        var indexPathsToReload = [NSIndexPath]()
        indexes.enumerateIndexesUsingBlock { (idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            let indexPath = NSIndexPath(forRow: idx, inSection: 0)
            let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems() as [NSIndexPath] // ATT: the  contains function requires this casting to [NSIndexPath]
            if (contains(visibleIndexPaths, indexPath)) {
                indexPathsToReload.append(indexPath)
            }
        }
        
        if (indexPathsToReload.count > 0) {
            self.collectionView.reloadItemsAtIndexPaths(indexPathsToReload)
        }
        
    }
    
    // MARK: - UISearchBarDelegate
    
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
