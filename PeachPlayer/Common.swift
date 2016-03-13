//
//  Common.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/9.
//  Copyright © 2016年 yxk. All rights reserved.
//

import Foundation
import AVFoundation

let SCREEN_WIDTH: CGFloat = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT: CGFloat = UIScreen.mainScreen().bounds.size.height

class Common {
    
    static func musicImageWithData(url: NSURL) -> UIImage {
        var data = NSData()
        let musicAsset = AVURLAsset(URL: url)
        for var format in musicAsset.availableMetadataFormats {
            for var metadataItem in musicAsset.metadataForFormat(format) {
                if metadataItem.commonKey == "artwork" {
                    data = metadataItem.value as! NSData
                    break
                }
            }
        }
        if data.length > 0 {
            return UIImage(data: data)!
        }
        return UIImage(data: data)!
    
    }
    
}