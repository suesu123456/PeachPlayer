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
        self.view.backgroundColor = UIColor.blackColor()
        self.title = data["name"] as? String
        initView()
        initPlayer()
        
        //默认进入该页面就是播放状态
        
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
        let lastButton = UIButton(frame: CGRectMake(x, 30, 40, 40))
        lastButton.setImage(UIImage(named: "last_piece"), forState: .Normal)
        lastButton.contentMode = .ScaleAspectFit
        bottomView.addSubview(lastButton)
        //播放，暂停按钮
        playButton = UIButton(frame: CGRectMake(lastButton.frame.maxX + 20, 10, 80, 80))
        playButton.setImage(data["image"] as! UIImage, forState: UIControlState.Normal)
        playButton.contentMode = .ScaleAspectFit
        playButton.layer.masksToBounds = true
        playButton.layer.cornerRadius = 40
        let ges = UITapGestureRecognizer(target: self, action: "handlePlay")
        ges.numberOfTapsRequired = 1
        ges.numberOfTouchesRequired = 1
        playButton.addGestureRecognizer(ges)
        bottomView.addSubview(playButton)
        //下一曲
        let nextButton = UIButton(frame: CGRectMake(playButton.frame.maxX + 20, 30, 40, 40))
        nextButton.setImage(UIImage(named: "next_piece"), forState: .Normal)
        nextButton.contentMode = .ScaleAspectFit
        bottomView.addSubview(nextButton)
        
    }
    
    func playButtonAnimation() {
        UIView.animateWithDuration(3.0, delay: 0, options: .CurveLinear,  animations: {  [weak self]() -> Void in
            if let weakSelf = self {
                weakSelf.playButton.transform = CGAffineTransformRotate(weakSelf.playButton.transform, CGFloat(M_PI))
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
        playButtonAnimation()
    }
    
    func handlePlay() {
        player.pause()
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event?.type == UIEventType.RemoteControl {
            
            switch event!.subtype {
                
            case UIEventSubtype.RemoteControlPause:
                //点击了暂停
                player.pause()
                break;
            case UIEventSubtype.RemoteControlNextTrack:
                //点击了下一首
                //[self playNextMusic];
                break;
            case UIEventSubtype.RemoteControlPreviousTrack:
                //点击了上一首
                //[self playPreMusic];
                //此时需要更改歌曲信息
                break;
            case UIEventSubtype.RemoteControlPlay:
                //点击了播放
                player.pause()
                break;
            default:
                break;
            }
        }

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
