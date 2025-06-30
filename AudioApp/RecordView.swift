//
//  RecordView2.swift
//  Audio Recorder
//
//  Created by Jonathan Tjandra on 8/12/24.
//  Copyright © 2024 Balaji. All rights reserved.
//


import SwiftUI
import AVFoundation

let ar =  AudioRecorder()

var str = UUID().uuidString

func swapFileLocations(url1: URL, url2: URL) throws {
    let fileManager = FileManager.default
    
   //   Check if both files exist
        guard fileManager.fileExists(atPath: url1.path), fileManager.fileExists(atPath: url2.path) else {
           return
        }
    
    // Create a temporary URL for backup
    
  
    let tempURL = url1.deletingLastPathComponent().appendingPathComponent(str)
    
    

    // Backup url1 to tempURL
    try fileManager.moveItem(at: url1, to: tempURL)
    

  
    
    // Move url2 to url1
    try fileManager.moveItem(at: url2, to: url1)
    
   
    
    // Move tempURL to url2
    try fileManager.moveItem(at: tempURL, to: url2)
    
}


@available(iOS 14.0, *)
struct RecordView : View {
    
    @StateObject var audioRec = ar
    
    @State var isRec = false
    @State var inProgress = false
    @State var time = 0.0

    // creating instance for recroding...
    @State var session : AVAudioSession!
    @State var alert = false
    // Fetch Audios...
    
    var title :  [String]{
        audioRec.load()
    }
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  
    var body: some View{
        
        if #available(iOS 16.0, *) {
            NavigationStack{
                ZStack{
                    LinearGradient.linearGradient(colors: [.indigo, .yellow], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                        .opacity(0.9)
                    VStack{
                        
                        Text(String(format: "Time: %.1f", time))
                            .onReceive(timer, perform: { _ in
                                time = audioRec.recorder?.currentTime ?? 0
                            })
                            .font(.title)
                            .padding()

                        
                        List{
                                                   Section(header : Text("My Recordings")
                                                       .textCase(nil)
                                                       .font(.title2)
                                                       .foregroundStyle(.orange)
                                                   ){ ForEach(self.audioRec.formatAudio) {i in
                                                       NavigationLink(destination:
                                                                       VStack{
                                                           PlayView(url: i.url, title: title[i.ind], inRecord: true).navigationBarBackButtonHidden(true)
                                                               .toolbar{
                                                                   ToolbarItem(placement : .bottomBar){
                                                                       NavigationStack{
                                                                           NavigationLink(destination: RecordView().navigationBarBackButtonHidden(true),
                                                                                          label: {
                                                                               Image(systemName: "house")
                                                                                   .padding()
                                                                                   .bold()
                                                                                   .foregroundStyle(.blue)
                                                                                   .font(.title)
                                                                           })
                                                                       }
                                                                   }
                                                               }
                                                       }
                                                                      ,
                                                                      label: { Text(
                                                                        
                                                                        title[i.ind]
                                                                      
                                                                      
                                                                      )})
                                                   }
                                                   .onDelete{
                                                      
                                                       do {
                                                           try FileManager.default.removeItem(at:  self.audioRec.audios[$0.first!])
                                                       }
                                                       catch {print(error.localizedDescription)}
                                                       self.audioRec.audios.remove(atOffsets: $0)
                                                       self.audioRec.audiosTitle.remove(atOffsets: $0)
                                                       audioRec.save()
                        
                                                   }
                                                   .onMove{
                                                       swapLoc(id0: $0, ind1: $1)
                                                       audioRec.audiosTitle.move(fromOffsets: $0, toOffset: $1)
                                                       audioRec.save()
            
                                                   }
                                                   }
                                               }.scrollContentBackground(.hidden)
                        
                        EditButton().padding()
                        
                        Button(action: {}){
                            NavigationLink(destination: RenameView().navigationBarBackButtonHidden(true), label: {Text("Rename Audios")})
                               
                        }
                    
                        
                        
                        Button(action : {
                            if inProgress == false {inProgress = true}
                            
                            
                            if isRec{
                                audioRec.pause()
                            }
                            else{
                                audioRec.record()
                            }
                            isRec.toggle()
                            
                        }){
                            
                            ZStack{
                                
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 70, height: 70)
                                if self.isRec{
                                    
                                    Circle()
                                        .stroke(Color.white, lineWidth: 6)
                                        .frame(width: 85, height: 85)
                                }
                                
                                Image(systemName: isRec ? "pause" : "play")
                                    .font(.largeTitle)
                            }
                        }.padding(.vertical, 25)
                        
                        if (self.inProgress){
                            Button("SAVE"){
                                self.inProgress = false
                                self.isRec = false
                                audioRec.stop()
                                
                                
                            }
                        }
                        
                    }
                }
                .navigationBarTitle("Record Audio")
            }
            .alert(isPresented: self.$alert, content: {
                
                Alert(title: Text("Error"), message: Text("Enable Acess"))
            })
            .onAppear {
                
                do{
                    
                    self.session = AVAudioSession.sharedInstance()
                    try self.session.setCategory(.playAndRecord)
                    
                    // requesting permission
                    // for this we require microphone usage description in info.plist...
                    self.session.requestRecordPermission { (status) in
                        
                        if !status{
                            self.alert.toggle()
                        }
                        else{
                            self.getAudios()
                            self.audioRec.update()
                        }
                    }
                    
                    
                }
                catch{
                    
                    print(error.localizedDescription)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func getAudios(){
        
        do{
            
            let result = try FileManager.default.contentsOfDirectory(at: audioRec.url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            self.audioRec.audios = result
            
        }
        catch{
            
            print(error.localizedDescription)
        }
    }
    
    func swapLoc(id0 : IndexSet, ind1 : Int){
        
        let ind0 = id0.first!
        
        let interval = (ind0 < ind1) ? 1 : -1
        
        let final = (ind0 < ind1) ? (ind1 - 1) : ind1
        
        for i in stride(from: ind0, to: final, by: interval) {
            
            let old = audioRec.audios[i]
            
            let new = audioRec.audios[i + interval]
            
            do {
                try swapFileLocations(url1: old, url2: new)
            }
            
            catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
}
