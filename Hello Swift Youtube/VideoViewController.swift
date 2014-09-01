//
//  VideoViewController.swift
//  Hello Swift Youtube
//
//  Created by Juan on 22/08/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    var itemJSONModel: YUItemJSONModel? = nil
    
    @IBOutlet var playerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        playerView.loadWithVideoId(itemJSONModel!.id.videoId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
