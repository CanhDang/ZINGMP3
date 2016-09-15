//
//  Song.swift
//  MP3ZING
//
//  Created by HoangHai on 8/24/16.
//  Copyright © 2016 CanhDang. All rights reserved.
//

import Foundation
import UIKit

struct Song {
    var title = ""
    var artistName = ""
    var thumbnail: UIImage
    var sourceOnline = ""
    var sourceLocal = ""
    var localThumbnail = ""
    let baseThumbnail = "http://image.mp3.zdn.vn//thumb/240_240/"
    var lyric = ""
    
    
    init (title: String, artistName: String, thumbnail: String, source: String, lyric: String){
        self.title = title
        self.artistName = artistName
        let thumbnailURL = baseThumbnail+thumbnail
        let dataImage = NSData(contentsOfURL:  NSURL(string: thumbnailURL)!)
        self.thumbnail = UIImage(data: dataImage!)!
        self.sourceOnline = source
        self.lyric = lyric
    }
    
    init(title: String, artistName: String, localThumbnail: String, localSource: String, lyric: String) {
        self.title = title
        self.artistName = artistName
        self.localThumbnail = localThumbnail
        let dataImage = NSData(contentsOfFile: self.localThumbnail)
        self.thumbnail = UIImage(data: dataImage!)!
        self.sourceLocal = localSource
        self.lyric = lyric
    }
}