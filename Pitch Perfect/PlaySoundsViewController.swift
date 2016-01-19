//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jared McFarland on 1/15/16.
//  Copyright © 2016 Jared McFarland. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer:AVAudioPlayer! = nil
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!

    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine = AVAudioEngine()
        let fileURL = receivedAudio.filePathUrl
        audioFile = try! AVAudioFile(forReading: fileURL)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: fileURL)
            audioPlayer.delegate = self
        } catch _ {
            audioPlayer = nil
        }
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()
        
        stopButton.hidden = true
    }

    func resetAudio() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioEngine.stop()
        audioEngine.reset()
        audioFile.framePosition = 0
    }
    
    func playAtRate(rate: Float) {
        resetAudio()
        stopButton.hidden = false
        audioPlayer.rate = rate
        audioPlayer.play()
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        resetAudio()
        stopButton.hidden = false
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        let audioFrameCount = AVAudioFrameCount(UInt32(audioFile.length))
        
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat, frameCapacity: audioFrameCount)
        try! audioFile.readIntoBuffer(buffer)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: buffer.format)
        audioEngine.connect(changePitchEffect, to: audioEngine.mainMixerNode, format: buffer.format)
        
        // There seems to be a bug in the timing of the scheduleFile:atTime:completionHandler:
        // Using workaround described here: http://stackoverflow.com/questions/29427253/completionhandler-of-avaudioplayernode-schedulefile-is-called-too-early
        audioPlayerNode.scheduleBuffer(buffer) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (!(self.audioPlayer.playing || audioPlayerNode.playing)) {
                    self.stopButton.hidden = true
                }
            });
        }
        
        try! audioEngine.start()
        
        audioPlayerNode.play()
        
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        stopButton.hidden = true
    }
    
    @IBAction func slowPlay(sender: UIButton) {
        playAtRate(0.5)
    }
    @IBAction func fastPlay(sender: UIButton) {
        playAtRate(2.0)
    }

    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stop(sender: UIButton) {
        resetAudio()
        stopButton.hidden = true
    }

}
