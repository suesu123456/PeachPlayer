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
    var datas: [[String: AnyObject]] = []
    
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
        
    }
    
    func initMenu() {
        self.numberOfItemsInRow = 3
        let item1 = DOPNavbarMenuItem(title: "item1", icon: nil)
        menu = DOPNavbarMenu(items: [item1,item1,item1], width: SCREEN_WIDTH, maximumNumberInRow: numberOfItemsInRow)
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
        
    }
    //UITableView Delegate DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        }
        cell?.selectionStyle = .None
        if datas.count > 0 {
            let dict:[String: AnyObject] = datas[indexPath.row]
            cell?.imageView?.image = dict["image"] as? UIImage
            cell?.textLabel?.text = dict["name"] as? String
            cell?.detailTextLabel?.text = (dict["size"] as? Int)?.description
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = PlayViewController()
        vc.data = datas[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

