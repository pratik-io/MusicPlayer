//
//  SongVc.swift
//  MusicPlayerInfo
//
//  Created by Petrick on 14/07/18.
//  Copyright © 2018 Petrick. All rights reserved.
//

import UIKit
import MediaPlayer

class SongListVc: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tbl_songList : UITableView!
    var arr_all_songs = [MPMediaItem]()

    
    let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    let remoCommandCenter = MPRemoteCommandCenter.shared()
    var nowPlayingIndex = 0
    var timer_updateInfo = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //to remove empty cell from bottom
        tbl_songList.tableFooterView = UIView()
        
        //for dinamic height of cell
        tbl_songList.rowHeight = 68
        tbl_songList.estimatedRowHeight = UITableViewAutomaticDimension
        askPermissonToGetSongs()
        
        self.title = "Songs"
        
        //TO Show Player Info in Lock Screen Must Add this two line
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateNowPlayingInfo(trackName:String,artistName:String,img:UIImage) {
        
        var art = MPMediaItemArtwork(image: img)
        if #available(iOS 10.0, *) {
            art = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 200)) { (size) -> UIImage in
                return img
            }
        }
        
        nowPlayingInfoCenter.nowPlayingInfo = [MPMediaItemPropertyTitle: trackName,
                                               MPMediaItemPropertyArtist: artistName,
                                               MPMediaItemPropertyArtwork : art]
        
        //For Play Event
        remoCommandCenter.playCommand.isEnabled = true
        remoCommandCenter.playCommand.addTarget(self, action: #selector(self.songPlayCommand))
        
        //For pause Event
        remoCommandCenter.pauseCommand.isEnabled = true
        remoCommandCenter.pauseCommand.addTarget(self, action: #selector(self.songPauseCommand))
        
        //For Next Event
        remoCommandCenter.nextTrackCommand.isEnabled = true
        remoCommandCenter.nextTrackCommand.addTarget(self, action: #selector(self.songNextCommand))
        
        //For Previous Event
        remoCommandCenter.previousTrackCommand.isEnabled = true
        remoCommandCenter.previousTrackCommand.addTarget(self, action: #selector(self.songPreviousCommand))
    }
    
    func startTimer() {
        timer_updateInfo.invalidate()
        timer_updateInfo = Timer(timeInterval: 1, target: self, selector: #selector(self.updateSongProgress), userInfo: nil, repeats: true)
        RunLoop.main.add(timer_updateInfo, forMode: .defaultRunLoopMode)
    }
    
    @objc func updateSongProgress() {
        
        nowPlayingInfoCenter.nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] = PPlayer.shared.playerCurrentTime().totalTim
        //nowPlayingInfoCenter.nowPlayingInfo[MPMediaItemElasp] = PPlayer.shared.playerCurrentTime().totalTim
    }
    
    
    @IBAction func songPlayCommand() {
        PPlayer.shared.playerPlay()
        startTimer()
    }
    
    @IBAction func songPauseCommand() {
        PPlayer.shared.playerPause()
        timer_updateInfo.invalidate()
    }
    
    @IBAction func songNextCommand() {
        timer_updateInfo.invalidate()
        if nowPlayingIndex + 1 < arr_all_songs.count {
            nowPlayingIndex = nowPlayingIndex + 1
        } else {
            nowPlayingIndex = 0
        }
        let item = arr_all_songs[nowPlayingIndex]
        PPlayer.shared.playWith(item)
        let resutl = getSongInfo(item: item)
        updateNowPlayingInfo(trackName: resutl.song, artistName: resutl.artist, img: resutl.imgSong)
        startTimer()
    }
    
    @IBAction func songPreviousCommand() {
        timer_updateInfo.invalidate()
        nowPlayingIndex = nowPlayingIndex - 1
        if nowPlayingIndex == -1 {
            nowPlayingIndex = arr_all_songs.count - 1
        }
        
        let item = arr_all_songs[nowPlayingIndex]
        PPlayer.shared.playWith(item)
        let resutl = getSongInfo(item: item)
        updateNowPlayingInfo(trackName: resutl.song, artistName: resutl.artist, img: resutl.imgSong)
        startTimer()
    }
    
    
    //MARK:- Request to access Device Songs
    func askPermissonToGetSongs() {
        let permissionStatus = MPMediaLibrary.authorizationStatus()
        
        if permissionStatus == .authorized {
            getAllSongs()
        } else if permissionStatus == .denied {
            
        } else if permissionStatus == .notDetermined {
            
            //Ask Permisson Here
            MPMediaLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    self.askPermissonToGetSongs()
                }
            }
            
        } else if permissionStatus == .restricted {
            
        }
    }
    
    //MARK:- Get All Song From Devices
    func getAllSongs() {
        
        let query = MPMediaQuery.songs()
        if let allsong = query.items {
            arr_all_songs = allsong
            self.tbl_songList.reloadData()
        }
        
    }
    
    
    

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_all_songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tbl_SongCell") as! Tbl_SongCell
        cell.selectionStyle = .none
        
        let item = arr_all_songs[indexPath.row]
        if let titleSong = item.value(forProperty: MPMediaItemPropertyTitle) as? String {
            cell.lbl_song_title.text = titleSong.capitalized
        }
        
        if let artwork = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork{
            cell.img_poster.image = artwork.image(at: CGSize(width: 200, height: 200))
        } else {
            cell.img_poster.image = #imageLiteral(resourceName: "default_poster")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arr_all_songs[indexPath.row]
        nowPlayingIndex = indexPath.row
        PPlayer.shared.playWith(item)
        let resutl = getSongInfo(item: item)
        updateNowPlayingInfo(trackName: resutl.song, artistName: resutl.artist, img: resutl.imgSong)
        startTimer()
    }
    
    
    func getSongInfo(item:MPMediaItem) -> (song:String,artist:String,imgSong:UIImage) {
        
        let titleSong = item.value(forProperty: MPMediaItemPropertyTitle) as? String ?? ""
        var image = #imageLiteral(resourceName: "default_poster")
        if let artwork = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork{
            image = artwork.image(at: CGSize(width: 200, height: 200))!
        }
        let artistSong = item.value(forProperty: MPMediaItemPropertyArtist) as? String ?? ""
        
        
        return (titleSong,artistSong,image)
    }
    
}


//TableView Custom Cell
class Tbl_SongCell : UITableViewCell {
    
    override func awakeFromNib() {
        img_poster.layer.cornerRadius = 6.0
        img_poster.layer.masksToBounds = true
    }
    
    @IBOutlet weak var lbl_song_title : UILabel!
    @IBOutlet weak var img_poster : UIImageView!
    
}
