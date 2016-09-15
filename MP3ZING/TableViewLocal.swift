//
//  TableViewLocal.swift
//  MP3ZING
//
//  Created by HoangHai on 8/24/16.
//  Copyright © 2016 CanhDang. All rights reserved.
//

import UIKit

class TableViewLocal: UIViewController, UITableViewDelegate, UITableViewDataSource, ParseLyric, MoveLocalHighLight{
    
    
    @IBOutlet weak var blurView: UIView!
    
    @IBOutlet weak var txtView_localLyric: UITextView!
    
    @IBOutlet weak var localTableView: UITableView!
    
    @IBOutlet weak var containnerView: UIView!
    
    var listSongs = [Song]()
    
    var audioPlayer = AudioPlayer.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurView.hidden = true
        txtView_localLyric.hidden = true
        
        localTableView.delegate = self
        localTableView.dataSource = self
        
        getData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getData()
        localTableView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var audioVC = AudioPlayerView()
        
        let audioPlayerView = self.childViewControllers
        
        for audioPlayerVC in audioPlayerView{
            if audioPlayerVC.isKindOfClass(AudioPlayerView){
                audioVC = audioPlayerVC as! AudioPlayerView
            }
        }
        
        audioVC.lyricDelegate = self
        audioVC.localHightLightDelegate = self
        
        highLightTableCell()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioPlayer.lyricShowing = false
        
        blurView.hidden = true
        txtView_localLyric.hidden = true
    }
    
    func getData() {
        
        listSongs.removeAll()
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do {
                print(dir)
                let folders = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir)
                for folder in folders {
                    if (folder != ".DS_Store") {
                        let info = NSDictionary(contentsOfFile: dir+"/"+folder+"/"+"info.plist")
                        print(info)
                        let title = info!["title"] as! String
                        let artistName = info!["artistName"] as! String
                        let thumbnailPath = info!["localThumbnail"] as! String
                        let lyric = info!["lyric"] as! String
                        
                        let sourceLocal = dir + "/\(title)/\(title).mp3"
                        let localThumbnail = dir + thumbnailPath
                        
                        
                        let currentSong = Song(title: title, artistName: artistName, localThumbnail: localThumbnail, localSource: sourceLocal, lyric: lyric)
                        listSongs.append(currentSong)
                    }
                }
                localTableView.reloadData()
                
                
            } catch let error as NSError{
                print(error)
            }
        }
    }
    
    //TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.imageView?.image = listSongs[indexPath.row].thumbnail
        cell.textLabel?.text = listSongs[indexPath.row].title
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "DELETE") { (action, index) in
            self.removeSongAtIndex(indexPath.row)
            self.localTableView.reloadData()
        }
        
        edit.backgroundColor = UIColor(red: 200/255, green: 123/255, blue: 100/255, alpha: 1)
        
        return [edit]
    }
    
    func removeSongAtIndex(index: Int) {
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do {
                let path = dir + "/\(listSongs[index].title)"
                try NSFileManager.defaultManager().removeItemAtPath(path)
                listSongs.removeAtIndex(index)
                self.localTableView.reloadData()
                
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let audioPlay = AudioPlayer.sharedInstance
        
        //        audioPlay.pathString = listSongs[indexPath.row].sourceLocal
        //        audioPlay.titleSong = "\(listSongs[indexPath.row].title)  Ca sy: \(listSongs[indexPath.row].artistName)"
        //        audioPlay.lyric = listSongs[indexPath.row].lyric
        
        audioPlay.generalListSongs = listSongs
        audioPlay.isSongLocal = true
        audioPlay.songPosition = indexPath.row
        
        audioPlay.setupInfo()
        audioPlay.setupAudio()
        
        NSNotificationCenter.defaultCenter().postNotificationName("setupObserveAudio", object: nil)
        
    }
    
    func lyric(audioPlayer: AudioPlayer) {
        
        blurView.hidden = !blurView.hidden
        txtView_localLyric.hidden = !txtView_localLyric.hidden
        
        txtView_localLyric.text = audioPlayer.lyric
    }
    
    func moveLocalHighLight(index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        self.localTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }
    
    func highLightTableCell(){
        
        if audioPlayer.isSongLocal != nil {
            if audioPlayer.isSongLocal == true {
                if let index = audioPlayer.songPosition {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.localTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
                }
            }
        }
    }
}
