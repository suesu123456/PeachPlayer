//
//  PlayViewController.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/9.
//  Copyright © 2016年 yxk. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class PlayViewController: UIViewController {

    var data: [String: AnyObject] = [String: AnyObject]()
    var player: AVAudioPlayer!
    var playButton: UIButton!
    var angle: CGFloat = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = data["name"] as? String
        initView()
        playButtonAnimation()
        //默认进入该页面就是播放状态
        //initPlayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initView() {
        let bottomView = UIView(frame: CGRectMake(0, SCREEN_HEIGHT - 100, SCREEN_WIDTH, 100))
        self.view.addSubview(bottomView)
        //上一曲
        var x = SCREEN_WIDTH / 5
        let lastButton = UIButton(frame: CGRectMake(x, 25, 50, 50))
        lastButton.setImage(UIImage(), forState: .Normal)
        lastButton.backgroundColor = UIColor.redColor()
        bottomView.addSubview(lastButton)
        //播放，暂停按钮
        playButton = UIButton(frame: CGRectMake(lastButton.frame.maxX + 10, 10, 80, 80))
        playButton.setImage(data["image"] as! UIImage, forState: UIControlState.Normal)
        playButton.contentMode = .ScaleAspectFit
        playButton.layer.masksToBounds = true
        playButton.layer.cornerRadius = 40
        bottomView.addSubview(playButton)
        //下一曲
        let nextButton = UIButton(frame: CGRectMake(playButton.frame.maxX + 10, 25, 50, 50))
        nextButton.setImage(UIImage(), forState: .Normal)
        nextButton.backgroundColor = UIColor.grayColor()
        bottomView.addSubview(nextButton)
        
    }
    
    func playButtonAnimation() {
        UIView.animateWithDuration(2.0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,  animations: {  [weak self]() -> Void in
            if let weakSelf = self {
                weakSelf.playButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }
            }, completion: { [weak self](Bool) -> Void in
                if let weakSelf = self {
                    weakSelf.playButtonAnimation()
                }
            })
    }
    
    func initPlayer() {
        player = try? AVAudioPlayer(data: data["data"] as! NSData, fileTypeHint: "mp3")
        player.play()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
