//
//  Player.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/10.
//  Copyright © 2016年 yxk. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
//
//enum LoopType: Int{
//    case nomailLoop = 0,
//    randomLoop = 1,
//    singleLoop = 2
//    
//}

class Player: NSObject, AVAudioPlayerDelegate {
    
    
    class var sharedInstance : Player {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : Player? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = Player()
            
        }
        return Static.instance!
    }
    var delegate: PlayVCDelegate!
    var player: AVAudioPlayer!
    var datas: [MusicModel] = []
    var data = MusicModel()
    
    var currentLoopType: LoopType = LoopType.nomailLoop
    var currentIndex: Int = 0
    
    func initPlayer(datas: [MusicModel], data: MusicModel) {
        
        self.datas = datas
        player = try? AVAudioPlayer(data: data.data, fileTypeHint: "mp3")
        player.delegate = self
        self.player.play()
        
    }
    
    func configNowPlayingInfoCenter() {
        self.data = datas[currentIndex]
        var dict = [String: AnyObject]()
        //歌曲名称
        dict["title"] = data.name
        //演唱者author,专辑名album,
        //缩略图
        var artwork = MPMediaItemArtwork(image: data.image)
        dict[MPMediaItemPropertyArtwork] = artwork
        //音乐剩余时长
        dict[MPMediaItemPropertyPlaybackDuration] = NSNumber(double: self.player.duration)
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = dict
    
    }
    //播放特定歌曲
    func willPlayAudioWithIndex(index: Int) {
        self.data = datas[index]
        player = try? AVAudioPlayer(data: data.data, fileTypeHint: "mp3")
        player.delegate = self
        player.prepareToPlay()
        self.delegate.updateUI(self.data)
    }
    
    
    
    
    //播放下一曲
    func playNextMusic() {
        switch currentLoopType {
            case LoopType.nomailLoop, LoopType.singleLoop:
                if currentIndex == datas.count - 1{
                    currentIndex = 0
                }else{
                    currentIndex += 1
                }
                break
            case LoopType.randomLoop:
                currentIndex = Int(arc4random()) % datas.count
                break
        }
        self.willPlayAudioWithIndex(currentIndex)
        self.player.play()
        
    }
    //播放上一曲
    func playPreMusic(){
        switch currentLoopType {
        case LoopType.nomailLoop, LoopType.singleLoop:
            if currentIndex == 0 {
                currentIndex = datas.count - 1
            }else{
                currentIndex -= 1
            }
            break
        case LoopType.randomLoop:
            currentIndex = Int(arc4random()) % datas.count
            break
        }
        self.willPlayAudioWithIndex(currentIndex)
        self.player.play()

    
    }
    //------delegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        switch currentLoopType {
        case LoopType.nomailLoop:
            if currentIndex == datas.count - 1 {
                currentIndex = 0
            }else{
                currentIndex += 1
            }
            break
        case LoopType.randomLoop:
            currentIndex = Int(arc4random()) % datas.count
            break
        case LoopType.singleLoop:
            break
            
        }
        self.willPlayAudioWithIndex(currentIndex)
        self.player.play()
    }
    

}
