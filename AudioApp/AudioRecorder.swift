//
//  AudioRecorder.swift
//  Audio Recorder
//
//  Created by Jonathan Tjandra on 8/12/24.
//  Copyright © 2024 Balaji. All rights reserved.
//

import AVFoundation
import SwiftUI
import Foundation

class AudioRecorder : NSObject, ObservableObject, AVAudioRecorderDelegate {
    
    var recorder : AVAudioRecorder?
    
    @Published var audios : [URL] = []
    
    
    @Published var audiosTitle : [String] = []
    
    
    var formatAudio : [RecordingFormat] {
        var res : [RecordingFormat] = []
        for (ind, elm) in audios.enumerated(){
            res.append(RecordingFormat(ind: ind, url: elm, title: title[ind]))
        }
        return res
    }
    
    var title : [String] {
        load()
    }
    
    
    
    let settings = [
        AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey : 12000,
        AVNumberOfChannelsKey : 1,
        AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
    ]
    
    
    let url : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var urlTitle : URL {try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)}
    
    var titleName : URL {
        urlTitle.appendingPathComponent("audioTitle").appendingPathExtension(for: .json)
    }
    
    var number = 0
    
    func record(){
        do {
            
            if self.recorder == nil {
                
                let str = UUID().uuidString
                let filName : URL = url.appendingPathComponent("myRcd\(self.audios.count + 1).m4a"+str)
                
                
                self.recorder = try AVAudioRecorder(url: filName, settings: settings)
                self.recorder?.delegate = self
            }
            
            self.recorder?.record()
        }
        catch{
            print(error.localizedDescription)
        }
      
    }
    
    func stop(){
     
        self.recorder?.stop()
        
        do{
            
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            let insertInd = getInsertIndex(audios, result)
            
            self.audios = result
            
            let now = Date()
            let dateformat = DateFormatter()
            dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let time = dateformat.string(from: now)
            
            audiosTitle.insert("Rec \(time)", at: insertInd)
            save()
            
            print("CALLED")
         
        }
        catch{
            print(error.localizedDescription)
        }
        self.recorder = nil
    }
    
    func pause(){
     
        self.recorder?.pause()
    }
    
    func load() -> [String]{
        var res : [String] = []
        do {
            
            let data = try Data(contentsOf: titleName)
            res = try JSONDecoder().decode( [String].self, from: data)
            
        }
        
        catch{
            print(error.localizedDescription)
        }
    
        return res
    }
    
    func update(){
        audiosTitle = title
    }
    
    func save(){
        do{
            let data = try JSONEncoder().encode(audiosTitle)
            try data.write(to: titleName)
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("FINISH A RECORDING")
        let _ = load()
    }
    
    func getInsertIndex(_ arr1 : [URL], _ arr2 : [URL])->Int{
        let length = arr1.count
        for ind in 0..<length{
            if arr1[ind] != arr2[ind] {return ind}
        }
        return length
    }
    
}

