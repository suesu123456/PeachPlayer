//
//  ViewController.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/8.
//  Copyright © 2016年 yxk. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DOPNavbarMenuDelegate, UITableViewDelegate, UITableViewDataSource {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMenu()
        initNav()
        initData()
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
        let vc = PlayViewController()
        let dicts = datas[indexPath.section]
        var values: [MusicModel] = []
        for (key, value) in dicts {
            values = value
        }
        let model: MusicModel = values[indexPath.row]
        vc.data = model
        vc.datas = values
        self.navigationController?.pushViewController(vc, animated: true)
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

