//
//  AudioViewController.swift
//  ByteItApp
//
//  Created by Tomás Vega on 6/7/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    var audioPlayer = AVAudioPlayer()
    var trackTimer = Timer()
    var mp = MPMusicPlayerController.systemMusicPlayer
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var trackTime: UILabel!
    @IBOutlet weak var pickButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVolumeSlider()
        pickButton.layer.zPosition = CGFloat(MAXFLOAT)
        updateInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateInfo()
    }
    
    @IBAction func pickSong(_ sender: UIButton) {
        print("pick")
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = false
        myMediaPickerVC.popoverPresentationController?.sourceView = sender
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mp.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true, completion: nil)
        let audio = mediaItemCollection.items[0]
        if let title = audio.title {
            trackTitle.text = title
        }
        if let artist = audio.artist {
            trackArtist.text = artist
        }
        trackTime.text = "00:00"
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func updateInfo() {
        if let audio = self.mp.nowPlayingItem {
            if let title = audio.title {
                self.trackTitle.text = title
            }
            if let artist = audio.artist {
                self.trackArtist.text = artist
            }
        }
    }
    
    func startTimer(time: Double) {
        trackTimer.invalidate()
        trackTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        trackTimer.invalidate()
        trackTimer = Timer()
    }
    
    func play() {
        mp.play()
        startTimer(time: 1.0)
    }
    
    func pause() {
        mp.pause()
        stopTimer()
    }
    
    @IBAction func playOrPauseMusic(_ sender: Any) {
        let state = mp.playbackState
        print(state)
        if state == MPMusicPlaybackState.playing  {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func rewind(_ sender: Any) {
        mp.beginSeekingBackward()
        stopTimer()
        startTimer(time: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.mp.endSeeking()
            self.stopTimer()
            self.startTimer(time: 1.0)
        }
    }
    
    @IBAction func fastforward(_ sender: Any) {
        mp.beginSeekingForward()
        stopTimer()
        startTimer(time: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.mp.endSeeking()
            self.stopTimer()
            self.startTimer(time: 1.0)
        }
    }
    
    @IBAction func nextSong(_ sender: UIButton) {
        self.mp.skipToNextItem()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateInfo()
        }
    }
    
    @IBAction func prevSong(_ sender: UIButton) {
        self.mp.skipToPreviousItem()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateInfo()
        }
    }
    
    let volumeSliderValues: [Float] = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    var volumeValue: Float = 1.0
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        let index = round(sender.value)
        volumeSlider.setValue(Float(index), animated: false)
        volumeValue = volumeSliderValues[Int(index)]
        updateVolume()
    }
    
    func setupVolumeSlider() {
        let numSteps = volumeSliderValues.count-1
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = Float(numSteps)
        volumeSlider.isContinuous = true
        let val = volumeSliderValues[numSteps/2]
        volumeSlider.setValue(5.0, animated: false)
        volumeValue = val
        updateVolume()
    }
    
    func updateVolume() {
        MPVolumeView.setVolume(volumeValue)
    }
    
    @objc func updateTime() {
        let currentTime = Int(mp.currentPlaybackTime)
        let minutes = currentTime/60
        let seconds = currentTime - minutes * 60
        print("updateTime")
        print(minutes, seconds)
        trackTime.text = String(format: "%02d:%02d", minutes,seconds) as String
    }
    
}
extension MPVolumeView {
    static let volumeView = MPVolumeView(frame: .zero)
    static func setVolume(_ volume: Float) {
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            volumeView.alpha = 0.000001
            window.addSubview(volumeView)
        }
    }
    static func setupHiddenMPVolume(_ view: UIView){
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            volumeView.alpha = 0.000001
            window.addSubview(volumeView)
        }
    }
}
