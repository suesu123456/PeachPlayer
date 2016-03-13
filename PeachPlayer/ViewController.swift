//
//  ViewController.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/8.
//  Copyright © 2016年 yxk. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

enum LoopType: Int{
    case nomailLoop = 0,
    randomLoop = 1,
    singleLoop = 2
    
}
protocol PlayVCDelegate {
    
    func updateUI(data: MusicModel)
}

class ViewController: UIViewController, DOPNavbarMenuDelegate, PlayVCDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {

    var numberOfItemsInRow: Int!
    var menu: DOPNavbarMenu!
    var datas: [[String: [MusicModel]]] = []
    var dirs: [String] = []
    var topView: UIView!
    var alertController: UIAlertController!
    
    
    var touchPoints: [NSValue] = []
    var sourceIndexPath: NSIndexPath = NSIndexPath()
    var sourceIndexPath2: NSIndexPath = NSIndexPath()
    var snapshot = UIView()
    @IBOutlet weak var tableView: UITableView!
    
    var podView: UIView!
    var circleImgView: UIImageView!
    var playButtonShow: UIButton!
    var playButton: UIButton!
    var nextButton: UIButton!
    var preButton: UIButton!
    var bottomView: UIView!
    var loopButton: UIButton!
    
    
    var currentDatas: [MusicModel] = []
    var currentData: MusicModel!
    var delegate: PlayVCDelegate!
    var player: AVAudioPlayer!
    var currentLoopType: LoopType = LoopType.nomailLoop
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMenu()
        initNav()
        initData()
        initPlayView()
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let ges = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        tableView.addGestureRecognizer(ges)
        alertController = UIAlertController(title: nil, message: "新建文件夹", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        

    }
    
    func initMenu() {
        self.numberOfItemsInRow = 3
        let item1 = DOPNavbarMenuItem(title: "列表", icon: nil)
        let item2 = DOPNavbarMenuItem(title: "文件", icon: nil)
        let item3 = DOPNavbarMenuItem(title: "设置", icon: nil)
        menu = DOPNavbarMenu(items: [item1,item2,item3], width: SCREEN_WIDTH, maximumNumberInRow: numberOfItemsInRow)
        menu.backgroundColor = UIColor.blackColor()
        menu.separatarColor = UIColor.whiteColor()
        menu.delegate = self
    }
    
    func initNav() {
        self.title = "🍑"
        let ges = UITapGestureRecognizer(target: self, action: "isHideMenu")
        ges.numberOfTapsRequired = 1
        ges.numberOfTouchesRequired = 1
        self.navigationController?.navigationBar.addGestureRecognizer(ges)
    }
    
   
    
    func initData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) , { [weak self]() -> Void in
            if let weakSelf = self {
               weakSelf.datas = FileManager.readList()
            }
            dispatch_async(dispatch_get_main_queue(), { [weak self]() -> Void in
                if let weakSelf = self {
                    if weakSelf.datas.count > 0 {
                        weakSelf.tableView.reloadData()
                    }
                }
                })
            })
    }
    
    func initPlayView() {
        podView = UIView(frame: CGRectMake(20, SCREEN_HEIGHT - 150, 140, 140))
        self.view.addSubview(podView)
        playButtonShow = UIButton(frame: CGRectMake(40, 40, 60, 60))
        playButtonShow.layer.cornerRadius = 30
        playButtonShow.layer.masksToBounds = true
        //向右轻扫手势
        let swipReg = UILongPressGestureRecognizer(target: self, action: "handleLP:")
        swipReg.minimumPressDuration = 0.2
        playButtonShow.addGestureRecognizer(swipReg)
        
        //画一个圆
        UIGraphicsBeginImageContext(podView.bounds.size);
        let context = UIGraphicsGetCurrentContext()
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(5, 5, 130, 130))
        //// Shadow Declarations
        let shadow = UIColor.lightGrayColor()
        let shadowOffset = CGSizeMake(0.1, 1.1)
        let shadowBlurRadius: CGFloat = 5
        //// Oval Drawing
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, (shadow as UIColor).CGColor)
        UIColor.lightGrayColor().setFill()
        ovalPath.fill()
        CGContextRestoreGState(context)
        UIColor.lightGrayColor().setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        circleImgView = UIImageView(image: img)
        podView.addSubview(circleImgView)
        podView.addSubview(playButtonShow)
        //播放，下一曲，上一曲，模式
        //播放，暂停按钮
        playButton = UIButton(frame: CGRectMake(60, 14, 20, 20))
        playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        playButton.contentMode = .ScaleAspectFit
        let ges = UITapGestureRecognizer(target: self, action: "handlePlay")
        ges.numberOfTapsRequired = 1
        ges.numberOfTouchesRequired = 1
        playButton.addGestureRecognizer(ges)
        podView.addSubview(playButton)
        //下一曲
        nextButton = UIButton(frame: CGRectMake(108, 60, 20, 20))
        nextButton.setImage(UIImage(named: "next_piece"), forState: .Normal)
        nextButton.contentMode = .ScaleAspectFit
        nextButton.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
        podView.addSubview(nextButton)
        //模式切换按钮
        loopButton = UIButton(frame: CGRectMake(60, 104, 20, 20))
        loopButton.setImage(UIImage(named: "repeat"), forState: .Normal)
        loopButton.contentMode = .ScaleAspectFit
        loopButton.addTarget(self, action: "changeLoopType", forControlEvents: .TouchUpInside)
        podView.addSubview(loopButton)
        //上一曲
        preButton = UIButton(frame: CGRectMake(13, 60, 20, 20))
        preButton.setImage(UIImage(named: "last_piece"), forState: .Normal)
        preButton.contentMode = .ScaleAspectFit
        preButton.addTarget(self, action: "pre", forControlEvents: .TouchUpInside)
        podView.addSubview(preButton)
        podView.hidden = true
        showPodouter(false)
        
    }
    
    //pod 外环显示
    func showPodouter(flag: Bool) {
        if flag {
            circleImgView.hidden = false
            playButton.hidden = false
            nextButton.hidden = false
            preButton.hidden = false
            loopButton.hidden = false
        }else{
            circleImgView.hidden = true
            playButton.hidden = true
            nextButton.hidden = true
            preButton.hidden = true
            loopButton.hidden = true
        }
    
    }
    
    func handleLP(ges: UILongPressGestureRecognizer) {
        let state = ges.state
        if state == .Began {
//            UIView.animateWithDuration(0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.circleImgView.hidden = false
//                self.circleImgView.bounds.size = CGSize(width: 30, height: 30)
//                self.circleImgView.alpha = 0.5
//                }) { (flag) -> Void in
                    self.circleImgView.bounds.size = CGSize(width: 60, height: 60)
                    self.circleImgView.alpha = 1
                    self.playButton.hidden = false
                    self.nextButton.hidden = false
                    self.preButton.hidden = false
                    self.loopButton.hidden = false
//                }

            
        }else if state == .Ended {
            
        }else{
            
        }
    
    }
    
    func podAnimation(flag: Bool) {
        if flag{
            UIView.animateWithDuration(0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.circleImgView.hidden = false
                self.circleImgView.bounds.size = CGSize(width: 30, height: 30)
                self.circleImgView.alpha = 0.5
                }) { (flag) -> Void in
                    self.circleImgView.bounds.size = CGSize(width: 60, height: 60)
                    self.circleImgView.alpha = 1
                    self.playButton.hidden = false
                    self.nextButton.hidden = false
                    self.preButton.hidden = false
                    self.loopButton.hidden = false
            }
        }else{
            UIView.animateWithDuration(0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                self.circleImgView.bounds.size = CGSize(width: 30, height: 30)
                self.circleImgView.alpha = 0.5
                }) { (flag) -> Void in
                    self.circleImgView.bounds.size = CGSize(width: 0, height: 0)
                    self.circleImgView.alpha = 0
                    self.circleImgView.hidden = true
                    self.playButton.hidden = true
                    self.nextButton.hidden = true
                    self.preButton.hidden = true
                    self.loopButton.hidden = true
            }
        }
    
    }
    
    
    func isHideMenu() {
        if menu.open {
            menu.dismissWithAnimation(true)
        }else{
            menu.showInNavigationController(self.navigationController)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //DOPNavbarMenuDelegate
    func didShowMenu(menu: DOPNavbarMenu!) {
        
    }
    
    func didDismissMenu(menu: DOPNavbarMenu!) {
        
    }
    
    func didSelectedMenu(menu: DOPNavbarMenu!, atIndex index: Int) {
        if index == 0 { // 列表
            
        }
        
        
    }
    
    //UITableView Delegate DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return datas.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datas.count > 0 {
            var values: [MusicModel] = []
            for (key, value) in datas[section] {
                values = value
            }
            return values.count
        }
         return 0
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0,0, SCREEN_WIDTH, 50))
        let titleLabel = UILabel(frame: CGRectMake(10, 10, SCREEN_WIDTH - 50, 30))
        titleLabel.text =  "📁" + [String](datas[section].keys)[0]
        view.addSubview(titleLabel)
        let addButton = UIButton(frame: CGRectMake(SCREEN_WIDTH - 50, 10, 40, 30))
        addButton.setTitle("＋", forState: .Normal)
        addButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
        addButton.addTarget(self, action: "addDir", forControlEvents: .TouchUpInside)
        view.addSubview(addButton)
        view.tag = section + 1
        return view
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        }
        cell?.selectionStyle = .None
        if datas.count > 0 {
            let dicts: [String: [MusicModel]] = datas[indexPath.section]
            var values: [MusicModel] = []
            for (key, value) in dicts {
                values = value
            }
            if values.count > 0 {
                let model: MusicModel = values[indexPath.row]
                cell?.imageView?.image = model.image
                cell?.textLabel?.text = model.name
                cell?.detailTextLabel?.text = model.size.description
            }
        
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dicts = datas[indexPath.section]
        var values: [MusicModel] = []
        for (key, value) in dicts {
            values = value
        }
        //默认进入该页面就是播放状态
        currentDatas = values
        currentData = values[indexPath.row]
        Player.sharedInstance.initPlayer(currentDatas, data:  currentData )
        Player.sharedInstance.delegate = self
        //如果是第一次要显示pod
        if podView.hidden {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.podView.hidden = false
                self.podView.alpha = 0.5
                }, completion: { (flag) -> Void in
                    if flag {
                        self.podView.alpha = 1
                        self.updateUI(self.currentData)
                    }
            })
            
        }else{
             self.updateUI(self.currentData)
        }
       
        
    }
    func handlePlay() {
        if Player.sharedInstance.player.playing {
            Player.sharedInstance.player.pause()
            playButton.setImage(UIImage(named: "play"), forState: .Normal)
        }else{
            Player.sharedInstance.player.play()
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        }
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
    func updateUI(data: MusicModel) {
        self.currentData = data
        self.title = data.name
        self.playButtonShow.setImage((currentData.image), forState: UIControlState.Normal)
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
   
   
    
    
    
       
    
    func isMoveToDir(location: CGPoint) {
        for var i in 1...datas.count {
            let header = self.tableView.viewWithTag(i)
            if CGRectContainsPoint(header!.frame, location){
                print("移动到第\(i-1)个文件夹")
                let alert = UIAlertController(title: "是否移动到[\([String](datas[i-1].keys)[0])]文件夹", message: nil, preferredStyle: .Alert)
                let cancleaction = UIAlertAction(title: "取消", style: .Cancel, handler: { (action) -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
                let okaction = UIAlertAction(title: "确定", style: .Default, handler: { [weak self](action) -> Void in
                    //移动到文件夹
                    if let weakSelf = self {
                        let dicts: [String: [MusicModel]] = weakSelf.datas[weakSelf.sourceIndexPath2.section]
                        var values: [MusicModel] = []
                        for (key, value) in dicts {
                            values = value
                        }
                        var sourceName: String = ""
                        if [String](weakSelf.datas[i-2].keys)[0] == "/" {
                            sourceName =  values[weakSelf.sourceIndexPath2.row].name
                        }else{
                            sourceName = [String](weakSelf.datas[i-2].keys)[0] + "/" + values[weakSelf.sourceIndexPath2.row].name
                        }
                       weakSelf.moveToDir(sourceName, toDir: [String](weakSelf.datas[i-1].keys)[0], alert: alert)
                        
                    }
                    
                })
                alert.addAction(cancleaction)
                alert.addAction(okaction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    func moveToDir(sourceName: String, toDir: String, alert: UIAlertController) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) , { [weak self]() -> Void in
            if let weakSelf = self {
                FileManager.moveToDir(sourceName, toDir: toDir)
            }
            dispatch_async(dispatch_get_main_queue(), { [weak self]() -> Void in
                if let weakSelf = self {
                    if weakSelf.datas.count > 0 {
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        weakSelf.tableView.reloadData()
                    }
                }
                })
            })
        
        
        
    }
    //长按拖拽
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        let state = sender.state
        var location = sender.locationInView(self.tableView)
        
        var indexPath = self.tableView.indexPathForRowAtPoint(location)
        
        switch state {
            case UIGestureRecognizerState.Began:
                if indexPath != nil { //是不是按在了cell上面
                    sourceIndexPath = indexPath!
                    sourceIndexPath2 = indexPath!
                    let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
                    //为拖动的cell添加一个快照
                    snapshot = self.customSnapshoFromView(cell!)
                    var center: CGPoint? = cell?.center
                    snapshot.center = center!
                    snapshot.alpha = 0.0
                    self.tableView.addSubview(snapshot)
                    //按下的瞬间执行动画
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        center?.y = location.y
                        self.snapshot.center = center!
                        self.snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
                        self.snapshot.alpha = 0.98
                        cell?.alpha = 0.0
                        }, completion: { (finished) -> Void in
                            cell!.hidden = true
                    })
                }
                break
            case UIGestureRecognizerState.Changed:
                self.touchPoints.append(NSValue(CGPoint: location))
                if self.touchPoints.count > 2 {
                    self.touchPoints.removeAtIndex(0)
                }
                var center = snapshot.center
                center.y = location.y
                let Ppoint = self.touchPoints.first?.CGPointValue()
                let Npoint = self.touchPoints.last?.CGPointValue()
                let moveX = Npoint!.x - Ppoint!.x;
                center.x += moveX;
                snapshot.center = center;
              
                // 是否移动了
                if indexPath != nil && indexPath != sourceIndexPath {
                    
                    // 更新数组中的内容
//                    self.datas.
//                    [self.dataArray exchangeObjectAtIndex:
//                        indexPath.row withObjectAtIndex:sourceIndexPath.row];
                    
                    // 把cell移动至指定行
                    self.tableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: indexPath!)
                    // 存储改变后indexPath的值，以便下次比较
                    //sourceIndexPath = indexPath!;
                }
            
            break
            default:
                //长安手势取消状态
                print(sourceIndexPath2.section)
                if indexPath?.row == nil && indexPath?.section == nil {
                    isMoveToDir(location)
                }
                self.touchPoints.removeAll()
                let cell = self.tableView.cellForRowAtIndexPath(sourceIndexPath)
                cell?.hidden = false
                cell?.alpha = 0
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.snapshot.center = (cell?.center)!
                    self.snapshot.transform = CGAffineTransformIdentity
                    self.snapshot.alpha = 0
                    cell?.alpha = 1.0
                    }, completion: { (finished) -> Void in
                        self.sourceIndexPath = NSIndexPath()
                        self.snapshot.removeFromSuperview()
                })
            break
        
        
        }
    }
    //创建cell的快照
    func customSnapshoFromView(inputView: UIView) -> UIView {
        //用cell的图层生成UIImage,方便显示
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //自定义这个快照的样子
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSizeMake(-5, 0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        return snapshot
    }
    func addDir() { //出现输入弹框
        
        alertController.addTextFieldWithConfigurationHandler { (txt) -> Void in
            txt.placeholder = "文件夹名称"
             NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("alertTextFieldDidChange:"), name: UITextFieldTextDidChangeNotification, object: txt)
        }
        
        let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) -> Void in
            let name = (self.alertController.textFields?.first!)! as UITextField
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
            //去新建文件夹
            self.addDirAction(name.text!)
            
        }
        okAction.enabled = false
        alertController.addAction(okAction)
       self.presentViewController(alertController, animated: true, completion: nil)
    }
    func alertTextFieldDidChange(notification: NSNotification){
        
        if (alertController != nil) {
            let login = (alertController!.textFields?.first)! as UITextField
            let okAction = alertController!.actions.last! as UIAlertAction
            okAction.enabled = login.text?.characters.count > 2
        }
    }
    func addDirAction(name: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) , { [weak self]() -> Void in
            if let weakSelf = self {
                FileManager.createDir(name)
            }
            dispatch_async(dispatch_get_main_queue(), { [weak self]() -> Void in
                if let weakSelf = self {
                    if weakSelf.datas.count > 0 {
                        weakSelf.alertController.dismissViewControllerAnimated(true, completion: nil)
                        weakSelf.tableView.reloadData()
                    }
                }
                })
            })
        
        
    
    }

}

