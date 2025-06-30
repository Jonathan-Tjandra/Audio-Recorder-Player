//
//  AudioPlayer.swift
//  Audio Recorder
//
//  Created by Jonathan Tjandra on 8/12/24.
//  Copyright © 2024 Balaji. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftUI

func delay(bySeconds seconds: Double, completion: @escaping () -> Void) {
    let dispatchTime = DispatchTime.now() + seconds
    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
        completion()
    }
}


class AudioPlayer : NSObject, ObservableObject, AVAudioPlayerDelegate{
    
    @Published var isPlaying = false
    var audioPlayer : AVAudioPlayer?
    var url : URL?
    var curTime : TimeInterval? {audioPlayer?.currentTime}
    var autoRep : Bool = false
    var autoCon : Bool {return autoCont}
    var finish : Bool = false

    func make(){
        do{
                audioPlayer = try AVAudioPlayer(contentsOf: url!)
                audioPlayer?.delegate = self
                audioPlayer?.enableRate = true
            
        }
        catch{
            print(error.localizedDescription)
        }
        
    }
    
    func play(){
        
                self.audioPlayer?.play()
                self.isPlaying = true
    }
    
    func pause(){
        audioPlayer?.pause()
        self.isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if autoRep {
            play()
        }
        
        else if autoCon{
            finish = true
        }
        
        else {
            isPlaying = false
        }
    }
}

