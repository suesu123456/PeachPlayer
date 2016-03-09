//
//  FileManager.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/9.
//  Copyright © 2016年 yxk. All rights reserved.
//

import Foundation

class FileManager: NSObject {
    
    static var appPath: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)[0]
    static var airdrop: String = "AirDrop"
    
    static func readList() -> [[String: AnyObject]] {
        var result: [[String: AnyObject]] = []
        let air = isExitFile(true, fileName: "", directory: airdrop)
        if air { //如果有传过文件
            let urls: [String] = applicationReadFileOfDirectoryAtPath("", directory: airdrop) as! [String]
            for var fileName in urls {
                let filePath = applicationFilePath(fileName, directory: airdrop)
                print(filePath)
                var dict: [String: AnyObject] = [String: AnyObject]()
                let data = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
                dict["data"] = data
                dict["name"] = fileName
                dict["size"] = data.length
                dict["image"] = Common.musicImageWithData(NSURL(fileURLWithPath: filePath))
                result.append(dict)
            }
        }
        return result
    }
    
    
    
    
    
    // 读取特定文件中数据（如：plist、text等）
    static func applicationReadDataToFileAtPath(dataTypeArray: Bool ,fileName: String ,directory: String) -> AnyObject{
        
        let filePath = applicationFilePath(fileName, directory: directory)
        
        if dataTypeArray {
            
            return NSArray().readFromPlistFile(filePath)
            
        }else{
            
            return NSDictionary().readFromPlistFile(filePath)
            
        }
        
    }
    // 读取文件夹中所有子文件（如：photo文件夹中所有image）
    static func applicationReadFileOfDirectoryAtPath(fileName: String ,directory: String) -> AnyObject{
        
        let filePath = applicationFilePath(fileName, directory: directory)
        
        let content = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(filePath)
        
        return content!
        
    }
    //是否存在文件或文件夹
    static func isExitFile(fileTypeDirectory: Bool, fileName: String, directory: String) -> Bool {
        let filePath = applicationFilePath(fileName, directory: directory)
        if fileTypeDirectory {
            return NSFileManager.defaultManager().fileExistsAtPath(filePath)
        }else{
            var isDir : ObjCBool = false
            return NSFileManager.defaultManager().fileExistsAtPath(filePath, isDirectory: &isDir)
        }
    }
    //拼接文件路径
    static func applicationFilePath(fileName: String, directory: String) -> String {
        if directory.isEmpty {
            return appPath.stringByAppendingString("/\(fileName)")
        }else{
            return (appPath as NSString).stringByAppendingPathComponent("/\(directory)/\(fileName)")
        }
        
    }
    
}