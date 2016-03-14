//
//  LocalModel.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/14.
//  Copyright © 2016年 yxk. All rights reserved.
//

import Foundation

class LocalModel: NSObject {
    
    static func saveSortData(data: [String]) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(data, forKey: "sort_data")
        defaults.synchronize()
    }
    static func getSortData() -> [String]{
        let data = NSUserDefaults.standardUserDefaults().objectForKey("sort_data")
        if  data != nil {
            let model = data as! [String]
            return model
        }
        return []
    }

}
