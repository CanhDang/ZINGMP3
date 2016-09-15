//
//  TableViewOnline.swift
//  MP3ZING
//
//  Created by HoangHai on 8/23/16.
//  Copyright © 2016 CanhDang. All rights reserved.
//

import UIKit

let kDOCUMENT_DIRECTORY_PATH = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true).first

class TableViewOnline: UIViewController, UITableViewDelegate, UITableViewDataSource, ParseLyric, MoveOnlineHighLight {
    
    @IBOutlet weak var blurView: UIView!
    
    @IBOutlet weak var txtView_onlineLyric: UITextView!
    
    @IBOutlet weak var onlineTableView: UITableView!
    
    @IBOutlet weak var lbl_week: UILabel!
    
    let baseUrl = "http://mp3.zing.vn/bang-xep-hang/bai-hat-Viet-Nam/IWZ9Z08I.html"
    
    var listSongs = [Song]()
    
    var audioPlayer = AudioPlayer.sharedInstance
    
    var iniWeek: Int!
    var iniYear: Int!
    var week: Int!
    var year: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurView.hidden = true
        txtView_onlineLyric.hidden = true
        
        
        
        onlineTableView.delegate = self
        onlineTableView.dataSource = self
        
        getInitDate(baseUrl)
        
        getData(linkMp3Url(self.iniWeek, year: self.iniYear))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let audioPlayerVC = self.childViewControllers[0] as! AudioPlayerView
        
        audioPlayerVC.lyricDelegate = self
        audioPlayerVC.onlineHightLightDelegate = self
        
        self.onlineTableView.reloadData()
        highLightTableCell()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioPlayer.lyricShowing = false
        blurView.hidden = true
        txtView_onlineLyric.hidden = true
        
    }
    
    func getInitDate(url: String){
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        
        let doc = TFHpple(HTMLData: data)
        var dayStr: String!
        var weekStr: String!
        var yearStr: String!
        
        
        if let elementWeek = doc.peekAtSearchWithXPathQuery("//div[@class='weekly-show']/p/strong")  {
            print("*********************************")
            print(elementWeek.content)
            weekStr = elementWeek.content
        }
        
        if let elementDay = doc.peekAtSearchWithXPathQuery("//div[@class='weekly-show']/p/span"){
            print(elementDay.content)
            dayStr = elementDay.content
        }
        
        lbl_week.text = weekStr + " " + dayStr
        
        let rangeWeek = weekStr.startIndex.advancedBy(5)..<weekStr.endIndex.advancedBy(-1)
        if let weekInt = Int(weekStr[rangeWeek]) {
            self.iniWeek = weekInt
        }
        print(self.iniWeek)
        
        if let elementYear = doc.peekAtSearchWithXPathQuery("//head/link") {
            print(elementYear)
            yearStr = elementYear.objectForKey("href")
            print(yearStr)
        }
        
        let rangeYear = yearStr.endIndex.advancedBy(-4)..<yearStr.endIndex
        
        if let yearInt = Int(yearStr[rangeYear]) {
            self.iniYear = yearInt
        }
        
        print(self.iniYear)
        
        self.week = self.iniWeek
        self.year = self.iniYear
        
    }
    
    func getWeekDay(url: String){
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        
        let doc = TFHpple(HTMLData: data)
        var dayStr: String!
        var weekStr: String!
       
        if let elementWeek = doc.peekAtSearchWithXPathQuery("//div[@class='weekly-show']/p/strong")  {
            print("*********************************")
            print(elementWeek.content)
            weekStr = elementWeek.content
        }
        
        if let elementDay = doc.peekAtSearchWithXPathQuery("//div[@class='weekly-show']/p/span"){
            print(elementDay.content)
            dayStr = elementDay.content
        }
        
        lbl_week.text = weekStr + " " + dayStr
    }
    
    func linkMp3Url(week: Int, year: Int) -> String {
        
        return baseUrl + "?w=\(week)&y=\(year)"
    }
    
    @IBAction func action_nextWeek(sender: UIButton) {
        if (year == iniYear){
            if (week < iniWeek) {
                week = week + 1
                changeData()
            }
        } else if (year == iniYear - 1) {
            if (week < 52) {
                week = week + 1
                changeData()
            } else {
                week = 1
                year = iniYear
                changeData()
            }
        }
    }
    
    
    @IBAction func action_previousWeek(sender: UIButton) {
        if (year == iniYear){
            if (week > 1) {
                week = week - 1
                changeData()

            } else {
                week = 52
                year = iniYear - 1
                changeData()
            }
        } else if (year == iniYear - 1) {
            if (week > 1){
                week = week - 1
                changeData()
            }
        }
    }
    
    func changeData(){
        let linkUrl = linkMp3Url(week, year: year)
        getData(linkUrl)
        getWeekDay(linkUrl)
        
    }
    
    func getData(url: String){
        
        listSongs.removeAll()
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        
        //print(String(data: data!, encoding: NSUTF8StringEncoding))
        let doc = TFHpple(HTMLData: data)
        
        
        if let elements = doc.searchWithXPathQuery("//h3[@class='title-item']/a") as? [TFHppleElement] {
            
            for element in elements {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let id = self.getID(element.objectForKey("href"))
                    let url = NSURL(string: "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
                    
                    var stringData = ""
                    
                    do {
                        stringData = try String(contentsOfURL: url!)
                    }
                    catch let error as NSError {
                        print(error)
                    }
                    
                    let lyricUrl = NSURL(string: "http://api.mp3.zing.vn/api/mobile/song/getlyrics?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
                    
                    var lyricStringData = ""
                    
                    do {
                        lyricStringData = try String(contentsOfURL: lyricUrl!)
                    } catch let error as NSError {
                        print(error)
                    }
                    
                    let lyricJson = self.convertStringToDictionary(lyricStringData)
                    
                    //print(stringData)
                    let json = self.convertStringToDictionary(stringData)
                    
                    if (json != nil) {
                        self.addSongToList(json!,lyricJson: lyricJson!)
                    }

                })
            }
        }
        
        onlineTableView.reloadData()
        
    }
    
    func getID(path: NSString) -> String {
        let id = (path.lastPathComponent as NSString).stringByDeletingPathExtension
        
        return id
    }
    
    func convertStringToDictionary(string: String) -> [String: AnyObject]? {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String: AnyObject]
                return json!
            }  catch {
                print("Error?json")
            }
        }
        
        return nil
    }
    
    func addSongToList(json: [String: AnyObject], lyricJson: [String: AnyObject]) {
        let title = json["title"] as! String
        let artistName = json["artist"] as! String
        let thumbnail = json["thumbnail"] as! String
        let source = json["source"]!["128"] as! String
        
        
        let lyric = lyricJson["content"] as! String
        
        
        let currentSong = Song(title: title, artistName: artistName, thumbnail: thumbnail, source: source, lyric: lyric)
        
        listSongs.append(currentSong)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.onlineTableView.reloadData()
        }
        
    }
    
    //UITableViewDelegate
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
        let edit = UITableViewRowAction(style: .Normal, title: "Download") { (action, index) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.downloadSong(indexPath.row)
            })
            dispatch_async(dispatch_get_main_queue()) {
                self.onlineTableView.reloadData()
            }
        }
        
        edit.backgroundColor = UIColor(red: 123/255, green: 98/255, blue: 168/255, alpha: 1.0)
        return [edit]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let audioPlay = AudioPlayer.sharedInstance
        
        //        audioPlay.pathString = listSongs[indexPath.row].sourceOnline
        //        audioPlay.titleSong = "\(listSongs[indexPath.row].title)  Ca sỹ: \(listSongs[indexPath.row].artistName)"
        //        audioPlay.lyric = listSongs[indexPath.row].lyric
        
        audioPlay.generalListSongs = listSongs
        audioPlay.isSongLocal = false
        audioPlay.songPosition = indexPath.row
        
        audioPlay.setupInfo()
        audioPlay.setupAudio()
        NSNotificationCenter.defaultCenter().postNotificationName("setupObserveAudio", object: nil)
        
    }
    
    
    func downloadSong(index: Int){
        let dataSong = NSData(contentsOfURL: NSURL(string: listSongs[index].sourceOnline)!)
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            let pathToWriteSong = "\(dir)/\(listSongs[index].title)"
            
            //create folder
            do {
                
                try NSFileManager.defaultManager().createDirectoryAtPath(pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            //ghi bai hat -> mp3
            writeDataToPath(dataSong!, path: "\(pathToWriteSong)/\(listSongs[index].title).mp3")
            
            
            //ghi thong tin bai hat -> plist
            writeInfoSong(listSongs[index], path: pathToWriteSong)
        }
        
        
    }
    
    func writeDataToPath(data: NSObject, path: String) {
        if let dataToWrite = data as? NSData {
            dataToWrite.writeToFile(path, atomically: true)
        } else if let dataInfo = data as? NSDictionary {
            dataInfo.writeToFile(path, atomically: true)
        }
        
        
    }
    
    func writeInfoSong(song: Song, path: String) {
        
        
        let dictData = NSMutableDictionary()
        dictData.setValue(song.title, forKey: "title")
        dictData.setValue(song.artistName, forKey: "artistName")
        dictData.setValue("/\(song.title)/thumbnail.png", forKey: "localThumbnail")
        dictData.setValue(song.sourceOnline, forKey: "sourceOnline")
        dictData.setValue(song.lyric, forKey: "lyric")
        
        //write info
        
        writeDataToPath(dictData, path: "\(path)/info.plist")
        
        //write thumbnail
        let dataThumbnail = NSData(data: UIImagePNGRepresentation(song.thumbnail)!)
        writeDataToPath(dataThumbnail, path: "\(path)/thumbnail.png")
    }
    
    
    func lyric(audioPlayer: AudioPlayer) {
        
        blurView.hidden = !blurView.hidden
        
        txtView_onlineLyric.hidden = !txtView_onlineLyric.hidden
        
        txtView_onlineLyric.text = audioPlayer.lyric
        
    }
    
    func moveOnlineHighLight(index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        self.onlineTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Bottom)
    }
    
    func highLightTableCell(){
        
        if audioPlayer.isSongLocal != nil {
            if audioPlayer.isSongLocal == false {
                if let index = audioPlayer.songPosition {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.onlineTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
                }
            }
        }
    }
    

    
}
