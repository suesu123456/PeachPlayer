//
//  NSArray.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/9.
//  Copyright © 2016年 yxk. All rights reserved.
//

import Foundation

extension NSArray {
    
    func writeToPlistFile(filepath: String) -> Bool {
        let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(self)
        let flag = data.writeToFile(filepath, atomically: true)
        return flag
    }
    func readFromPlistFile(filepath: String) -> NSArray {
        let data: NSData = NSData.dataWithContentsOfMappedFile(filepath) as! NSData
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSArray
    }
}
