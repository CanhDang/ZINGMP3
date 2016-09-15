//
//  AudioPlayerView.swift
//  MP3ZING
//
//  Created by HoangHai on 8/25/16.
//  Copyright © 2016 CanhDang. All rights reserved.
//

import UIKit
import AVFoundation

protocol ParseLyric: class {
    func lyric(audioPlayer: AudioPlayer)
}

//Move highlight in local table view
protocol MoveLocalHighLight: class {
    func moveLocalHighLight(index: Int)
    
}

protocol MoveOnlineHighLight: class {
    func moveOnlineHighLight(index: Int)
}


class AudioPlayerView: UIViewController {

    
    
    let audioPlayer = AudioPlayer.sharedInstance
    
    weak var lyricDelegate: ParseLyric!
    weak var localHightLightDelegate: MoveLocalHighLight!
    weak var onlineHightLightDelegate: MoveOnlineHighLight!
   
    @IBOutlet weak var btn_lyric: UIButton!
    
    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var sld_Duration: UISlider!
    
    @IBOutlet weak var lbl_CurrentTime: UILabel!
    
    @IBOutlet weak var lbl_TotalTime: UILabel!
    
    @IBOutlet weak var btn_Play: UIButton!
    
    @IBOutlet weak var sld_Volume: UISlider!
    
    @IBOutlet weak var btn_nextSong: UIButton!
    
    @IBOutlet weak var btn_previousSong: UIButton!
    

    var checkAddObserveAudio = false
    var isLyricHightLight = false
    var generalListSongs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_Play.enabled = false
        btn_lyric.enabled = false
        btn_nextSong.enabled = false
        btn_previousSong.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setupObserveAudio), name: "setupObserveAudio", object: nil)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupObserveAudio()
        
    }
    

    func changeInfoView() {
        changeInfoSong()
        addThumbImgForButton()
        changeImageLyricButton()
    }

    func changeInfoSong(){
        lbl_title.text = audioPlayer.titleSong
    }
    
    func addThumbImgForButton(){
        if (audioPlayer.playing == true) {
            btn_Play.setImage(UIImage(named: "play.png"), forState: .Normal)
        } else {
            btn_Play.setImage(UIImage(named:"pause.png"), forState: .Normal)
        }
    }
    
    func changeImageLyricButton(){
        if (audioPlayer.lyricShowing == true) {
            btn_lyric.setImage(UIImage(named: "lyric_hightlight.png"), forState: .Normal)
        } else {
            btn_lyric.setImage(UIImage(named: "lyric.png"), forState: .Normal)
        }
    }
    
    func setupObserveAudio(){
        if (audioPlayer.playing && !checkAddObserveAudio) {
            checkAddObserveAudio = true
            
            //enable button
            btn_Play.enabled = true
            btn_lyric.enabled = true
            btn_nextSong.enabled = true
            btn_previousSong.enabled = true
            
            _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidReachEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        }
        changeInfoView()
    }
    
    func playerItemDidReachEnd(notification: NSNotification){
        if (audioPlayer.repeating){
            audioPlayer.player.seekToTime(kCMTimeZero)
            audioPlayer.player.play()
        } else {
            audioPlayer.playing = false
            changeInfoView()
        }
    }
    
    
    func timeUpdate(){
        
        
        audioPlayer.duration = Float((audioPlayer.player.currentItem?.duration.value)!) / Float((audioPlayer.player.currentItem?.duration.timescale)!)
        
        audioPlayer.currentTime = Float(audioPlayer.player.currentTime().value) / Float(audioPlayer.player.currentTime().timescale)
        
        let m = Int(floor(audioPlayer.currentTime/60))
        let s = Int(round(audioPlayer.currentTime - Float(m)*60))
        
        if (audioPlayer.duration > 0) {
            let mduration = Int(floor(audioPlayer.duration/60))
            let sduration = Int(round(audioPlayer.duration - Float(mduration)*60))
            
            self.lbl_CurrentTime.text = String(format: "%02d", m) + ":" + String(format: "%02d", s)
            
            self.lbl_TotalTime.text = String(format: "%02d", mduration) + ":" + String(format: "%02d", sduration)
            
            self.sld_Duration.value = Float(audioPlayer.currentTime/audioPlayer.duration)
            self.sld_Volume.value = audioPlayer.player.volume
            
        }
    }
   
    
    //Action
    
    @IBAction func action_repeatSong(sender: UISwitch){
        audioPlayer.action_repeatSong(sender.on)
    }
    
    @IBAction func action_PlayPause(sender: UIButton){
        audioPlayer.action_PlayPause()
        addThumbImgForButton()
    }
    
    @IBAction func sld_Duration(sender: UISlider){
        audioPlayer.action_sld_Duration(sender.value)
    }
    
    @IBAction func sld_Volume(sender: UISlider){
        audioPlayer.action_sld_Volumne(sender.value)
    }
    
    @IBAction func action_showLyric(sender: UIButton){
        audioPlayer.action_lyric()
        changeImageLyricButton()
        
        self.lyricDelegate?.lyric(audioPlayer)
    }
    
    @IBAction func action_nextSong(sender: UIButton){
        audioPlayer.action_nextSong()
        changeInfoSong()
        if audioPlayer.isSongLocal == true {
            self.localHightLightDelegate?.moveLocalHighLight(audioPlayer.songPosition)
        } else {
            self.onlineHightLightDelegate?.moveOnlineHighLight(audioPlayer.songPosition)
        }
        
    }
    
    @IBAction func action_previousSong(sender: UIButton){
        audioPlayer.action_previousSong()
        changeInfoSong()
        if audioPlayer.isSongLocal == true {
            self.localHightLightDelegate?.moveLocalHighLight(audioPlayer.songPosition)
        } else {
            self.onlineHightLightDelegate?.moveOnlineHighLight(audioPlayer.songPosition)
        }
    }
    
    
}



