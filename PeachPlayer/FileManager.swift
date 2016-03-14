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
    
    //读取所有文件列表
    static func readList() ->  [MusicModel] {
        var result: [MusicModel] = []
        let air = isExitFile(true, fileName: "", directory: airdrop)
        var urls: [String] = []
        if air { //如果有传过文件
            urls = applicationReadFileOfDirectoryAtPath("", directory: airdrop) as! [String]
            for var fileName in urls {
                let filePath = applicationFilePath(fileName, directory: airdrop)
                let model = MusicModel()
                let data = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
                model.name = fileName
                model.size = Float(data.length) / 1024.0 / 1024.0
                model.image = Common.musicImageWithData(NSURL(fileURLWithPath: filePath))
                model.data = data
                result.append(model)
            }
        }
        let local = LocalModel.getSortData()
        if local.count == 0 {
            LocalModel.saveSortData(urls)
            return result
        }
        if local == urls {
            return result
        }
        //重新对result排序
        var result2: [MusicModel] = []
        for var b in local {
            for var a in result {
                if b == a.name {
                    result2.append(a)
                }
            }
        }
        return result2
    }

    static func removeFile(name: String) -> Bool {
        return applicationRemoveFileAtPath(name, directory: airdrop)
    
    }
//    static func readList() -> [[String: [MusicModel]]] {
//        var result: [[String: [MusicModel]]] = []
//        let air = isExitFile(true, fileName: "", directory: airdrop)
//        if air { //如果有传过文件
//            let urls: [String] = applicationReadFileOfDirectoryAtPath("", directory: airdrop) as! [String]
//            var i = 0
//            var dir = "/"
//            let dict = [dir: [MusicModel]()]
//            result.append(dict)
//            for var fileName in urls {
//                let filePath = applicationFilePath(fileName, directory: airdrop)
//                var flag: ObjCBool = false
//                NSFileManager.defaultManager().fileExistsAtPath(filePath, isDirectory: &flag)
//                if flag {
//                   //是文件夹
//                    let dict = [fileName: [MusicModel]()]
//                    result.append(dict)
//                    dir = fileName
//                    i++
//                    continue
//                }
//                var model = MusicModel()
//                let data = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
//                model.name = fileName
//                model.size = data.length
//                model.image = Common.musicImageWithData(NSURL(fileURLWithPath: filePath))
//                model.data = data
//                result[0]["/"]?.append(model)
//            }
//        }
//        return result
//    }
//    
    //在根目录新建文件夹
    static func createDir(name: String) {
        self.applicationCreatFileAtPath(true, fileName: "", directory: airdrop + "/" + name)
    }
    
    //移动文件到文件夹
    static func moveToDir(sourceFile: String, toDir: String) {
        let sourcePath = applicationFilePath(sourceFile, directory: airdrop)
        let toPath = applicationFilePath("", directory: airdrop + "/" + toDir)
        try? NSFileManager.defaultManager().moveItemAtPath(sourcePath, toPath: toPath)
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
    //创建文件或文件夹在指定路径下
    static func applicationCreatFileAtPath(fileTypeDirectory: Bool ,fileName: String ,directory: String) -> Bool {
        
        let filePath = applicationFilePath(fileName, directory: directory)
        let isExit = isExitFile(fileTypeDirectory, fileName: fileName, directory: directory)
        
        if isExit {
            print("已经存在文件或文件夹")
            return false
        }else{
            if fileTypeDirectory {//文件夹
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(filePath, withIntermediateDirectories: true, attributes: nil)
                    return true
                } catch _ {
                    return false
                }
            }else{//普通文件（图片、plist、txt等等）
                return NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
            }
        }
    }
    static func applicationRemoveFileAtPath(fileName: String ,directory: String) -> Bool{
        
        let filePath = applicationFilePath(fileName, directory: directory)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
            return true
        } catch _ {
            return false
        }
        
    }


}