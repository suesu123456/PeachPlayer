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


//protocol PlayVCDelegate {
//    
//    func updateUI()
//}


class PlayViewController: UIViewController {

    var data = MusicModel()
    var datas: [MusicModel] = []
    var playButton: UIButton!
    var loopButton: UIButton!
    var progress: UISlider!
    var angle: CGFloat = 1
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.title = data.name
        initView()
        //默认进入该页面就是播放状态
        Player.sharedInstance.initPlayer(datas,data:  data )
       // Player.sharedInstance.delegate = self
        
        
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initView() {
        // 进度条
        let progress = UISlider(frame: CGRectMake(20, 94, SCREEN_WIDTH - 40, 0.1))
        progress.backgroundColor = UIColor.whiteColor()
        progress.maximumValue = 2.0
        progress.minimumValue = 0.0
        progress.thumbTintColor = UIColor.whiteColor()
        progress.minimumTrackTintColor = UIColor.grayColor()
        progress.setThumbImage(UIImage(named: "heart"), forState: .Normal)
        progress.value = 1 / 2
        
        
        self.view.addSubview(progress)
        
        let bottomView = UIView(frame: CGRectMake(0, SCREEN_HEIGHT - 100, SCREEN_WIDTH, 100))
        self.view.addSubview(bottomView)
         var x = (SCREEN_WIDTH - 100) / 3
        //模式切换按钮
        loopButton = UIButton(frame: CGRectMake(20, 40, 30, 30))
        loopButton.setImage(UIImage(named: "repeat"), forState: .Normal)
        loopButton.contentMode = .ScaleAspectFit
        loopButton.addTarget(self, action: "changeLoopType", forControlEvents: .TouchUpInside)
        bottomView.addSubview(loopButton)
        //上一曲
        let lastButton = UIButton(frame: CGRectMake(x, 30, 40, 40))
        lastButton.setImage(UIImage(named: "last_piece"), forState: .Normal)
        lastButton.contentMode = .ScaleAspectFit
        lastButton.addTarget(self, action: "pre", forControlEvents: .TouchUpInside)
        bottomView.addSubview(lastButton)
        //播放，暂停按钮
        playButton = UIButton(frame: CGRectMake(lastButton.frame.maxX + 20, 10, 80, 80))
        playButton.setImage(data.image, forState: UIControlState.Normal)
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
        nextButton.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
        bottomView.addSubview(nextButton)
        //播放列表按钮
        let listButton = UIButton(frame: CGRectMake(SCREEN_WIDTH - 50, 40, 30, 30))
        listButton.setImage(UIImage(named: "list"), forState: .Normal)
        listButton.contentMode = .ScaleAspectFit
        listButton.addTarget(self, action: "showList:", forControlEvents: .TouchUpInside)
        bottomView.addSubview(listButton)
        
        
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
    
    func handlePlay() {
         Player.sharedInstance.player.pause()
    }
    func pre() {
        Player.sharedInstance.playPreMusic()
    }
    func next() {
        Player.sharedInstance.playNextMusic()
    }
    func showList(sender: UIButton) {
        
        
        let view = UIView(frame: CGRectMake(0,0,111,111))
        view.backgroundColor = UIColor.redColor()
        let point = CGPoint(x: SCREEN_WIDTH - 35, y: SCREEN_HEIGHT - 30)
        KWPopoverView.showPopoverAtPoint(point, inView: self.view, withContentView: view)
    
    }
    func updateUI() {
        self.title = data.name
        self.playButton.setImage((data.image), forState: UIControlState.Normal)
        progress.value = Float(Player.sharedInstance.player.currentTime) / Float(Player.sharedInstance.player.duration)
    }
    
    func changeLoopType() {
        if Player.sharedInstance.currentLoopType == LoopType.nomailLoop {
            MBProgressHUD.showSuccess("随机播放", toView: self.view)
            Player.sharedInstance.currentLoopType = LoopType.randomLoop
            self.loopButton.setImage(UIImage(named: "random"), forState: .Normal)
        }else if Player.sharedInstance.currentLoopType == LoopType.randomLoop {
            MBProgressHUD.showSuccess("单曲循环", toView: self.view)
            Player.sharedInstance.currentLoopType = LoopType.singleLoop
            self.loopButton.setImage(UIImage(named: "repeat"), forState: .Normal)
        }else {
            MBProgressHUD.showSuccess("列表循环", toView: self.view)
            Player.sharedInstance.currentLoopType = LoopType.nomailLoop
            self.loopButton.setImage(UIImage(named: "repeat"), forState: .Normal)
        }
    }
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event?.type == UIEventType.RemoteControl {
            
            switch event!.subtype {
                
            case UIEventSubtype.RemoteControlPause:
                //点击了暂停
                Player.sharedInstance.player.pause()
                break;
            case UIEventSubtype.RemoteControlNextTrack:
                //点击了下一首
                Player.sharedInstance.playNextMusic()
                break;
            case UIEventSubtype.RemoteControlPreviousTrack:
                //点击了上一首
                Player.sharedInstance.playPreMusic()
                break;
            case UIEventSubtype.RemoteControlPlay:
                //点击了播放
                Player.sharedInstance.player.play()
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
