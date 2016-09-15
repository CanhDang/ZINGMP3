//
//  AudioPlayer.swift
//  MP3ZING
//
//  Created by HoangHai on 8/24/16.
//  Copyright © 2016 CanhDang. All rights reserved.
//

import UIKit
import AVFoundation


class AudioPlayer: NSObject {
    class var sharedInstance: AudioPlayer {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AudioPlayer? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = AudioPlayer()
        }
        return Static.instance!
    }
    
    var pathString = ""
    var repeating = false
    var playing = false
    var duration = Float()
    var currentTime = Float()
    var titleSong = ""
    var lyric = ""
    var lyricShowing = false
    var generalListSongs = [Song]()
    var songPosition: Int!
    var isSongLocal: Bool!
    
    var player = AVPlayer()
    
    func setupInfo(){
        if  isSongLocal == true {
            pathString = generalListSongs[songPosition].sourceLocal
        } else {
            pathString = generalListSongs[songPosition].sourceOnline
        }

        titleSong = "\(generalListSongs[songPosition].title)  Ca sy: \(generalListSongs[songPosition].artistName)"
        lyric = generalListSongs[songPosition].lyric
        
    }
    
    func setupAudio() {
        
        var url = NSURL()
        
        if let checkURL = NSURL(string: pathString) {
            url = checkURL
        } else {
            url = NSURL(fileURLWithPath: pathString)
        }
        
        let playerItem = AVPlayerItem(URL: url)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1.0
        player.volume = 0.5
        player.play()
        playing = true
        repeating = true
        lyricShowing = false
    }
    
    //Action
    func action_repeatSong(repeatSong: Bool) {
        
        if (repeatSong == true) {
            repeating = true
        } else {
            repeating = false
        }
        
    }
    
    func action_PlayPause(){
        if (playing == false) {
            player.play()
            playing = true
        } else {
            player.pause()
            playing = false
        }
    }
    
    func action_sld_Duration(value: Float){
        let timeToSeek = value * duration
        let time = CMTimeMake(Int64(timeToSeek), 1)
        player.seekToTime(time)
        
    }
    
    
    func action_sld_Volumne(value: Float){
        player.volume = value
    }
    
    func action_lyric(){
        if (lyricShowing == false){
            lyricShowing = true
        } else {
            lyricShowing = false
        }
    }
    
    func action_nextSong() {
        if songPosition < generalListSongs.count - 1 {
            songPosition = songPosition + 1
        } else {
            songPosition = 0
        }
        
        setupInfo()
        setupAudio()
        
    }
    
    func action_previousSong() {
        if songPosition > 0 {
            songPosition = songPosition - 1
        } else {
            songPosition = generalListSongs.count - 1
        }
        
        setupInfo()
        setupAudio()
    }
    
}




