//
//  PPlayer.swift
//  MusicPlayerInfo
//
//  Created by Petrick on 14/07/18.
//  Copyright © 2018 Petrick. All rights reserved.
//

import UIKit
import MediaPlayer

class PPlayer: NSObject {

    static let shared = PPlayer()
    
    private var myAvPlayer = AVPlayer()
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    override init() {
        
        try! self.audioSession.setCategory(AVAudioSessionCategoryPlayback)
        try! self.audioSession.setActive(true)                
    }
    
    
    func playWith(_ item : MPMediaItem) {
        
        if let url = item.assetURL {
            let asset = AVAsset(url: url)
            myAvPlayer = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            myAvPlayer.play()
            myAvPlayer.volume = 0.6
        }
    }
    
    func playerPlay() {
        myAvPlayer.play()
    }
    
    func playerPause() {
        myAvPlayer.pause()
    }
    
    func playerCurrentTime() -> (nowTim:Double,totalTim:Double) {        
        return (myAvPlayer.currentTime().seconds,(myAvPlayer.currentItem?.duration.seconds)!)
    }
    
}
