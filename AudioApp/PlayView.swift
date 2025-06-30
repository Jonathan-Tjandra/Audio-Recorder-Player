//
//  PlayView.swift
//  Audio Recorder
//
//  Created by Jonathan Tjandra on 8/12/24.
//

import SwiftUI
import AVFoundation
import Foundation


var autoCont = false


@available(iOS 14.0, *)
struct PlayView : View, Identifiable{
        
    let id = UUID()

    var fileName : String!
    var extensionName : String!
    var url : URL!
    var title : String


    var prev : Prev?
    var next : Next?
    var ind : Int?
    var inRecord : Bool

    @StateObject var rec = ar
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingDeleteAlert = false
        
    init(file : String, _ extensionName: String, title : String = "", prev : Prev? = nil, next : Next? = nil, ind : Int? = nil, inRecord : Bool = false){
        self.fileName = file
        self.extensionName = extensionName
        self.myRec = false
        self.title = (title == "") ? "" : title
        self.prev = prev
        self.next = next
        self.ind = ind
        self.inRecord = inRecord
    }

    init(url : URL, title : String = "", prev : Prev? = nil, next : Next? = nil, inRecord : Bool = false){
        self.url = url
        self.myRec = true
        self.title = (title == "") ? url.relativeString : title
        self.prev = prev
        self.next = next
        self.inRecord = inRecord
      }
        
    @State var volume : Float = 1.0
    @State var speed : Float = 1.0
    @State var isEditVol = false
    @State var isEditSpeed = false
    @State var isEditTime = false
    @StateObject var audioPlayer : AudioPlayer = AudioPlayer()
    @State var progress : TimeInterval = 0.0
    @State var duration = 5.0
    @State var autoRepeat = false
    
    @State var hasContinue = false

    @State var changer = false

    @State var isAlert = false

    @State var relTime = 0.0

    var autoCon : Bool {
        return autoCont
    }

    var rate : Double {
        Double(speed)
    }
        
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var myRec : Bool
        
    func getURL() -> URL?{
        if self.myRec{
            return self.url
        }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: extensionName) else {return nil}
        return url
    }
    
    func go_next(){next?.go_next()}
    
    func formatTime(time : TimeInterval?)->String{
        if var time = time {
            time += 0.5
            let hour = Int(time/3600)
            let minute = Int(time/60)
            let second = Int(time)%60
            let strhour = hour < 10 ? "0\(hour)" : "\(hour)"
            let strmin = minute < 10 ? "0\(minute)" : "\(minute)"
            let strsec = second < 10 ? "0\(second)" : "\(second)"
            
            if hour == 0 {
                return strmin+":"+strsec
            }
            return  strhour+":"+strmin+":"+strsec
        }
        return ""
    }
    
    func copyItem(){
        let fileManager = FileManager.default
        let str = UUID().uuidString
        let copyLoc = url.deletingLastPathComponent().appendingPathComponent(str)
        
        do {
            try fileManager.copyItem(at: url, to: copyLoc)
            let result = try FileManager.default.contentsOfDirectory(at: ar.url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            let insertInd = ar.getInsertIndex(ar.audios, result)
            
            ar.audios = result
            ar.audiosTitle.insert("Copy of "+title, at: insertInd)
        }
        catch{
            print(error.localizedDescription)
        }
    }
        
    func deleteRecording() {
        guard myRec, let urlToDelete = self.url else { return }

        do {
            try FileManager.default.removeItem(at: urlToDelete)

            if let indexToRemove = rec.audios.firstIndex(of: urlToDelete) {
                rec.audios.remove(at: indexToRemove)
                if rec.audiosTitle.indices.contains(indexToRemove) {
                    rec.audiosTitle.remove(at: indexToRemove)
                }
            }
            
            rec.save()
            presentationMode.wrappedValue.dismiss()

        } catch {
            print("Error deleting recording: \(error.localizedDescription)")
        }
    }
        
    @available(iOS 14.0, *)
    var body : some View {
        ZStack{
            if #available(iOS 15.0, *) {
                LinearGradient.linearGradient(colors: [.indigo, .yellow], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    .opacity(0.9)
            } else {
                // Fallback on earlier versions
            }
            
            VStack{
                Text(self.title)
                    .font(.title)
                    .bold()
                
                SliderView(progress: $progress, max: $duration, f: {edit in
                        isEditTime = edit
                        audioPlayer.pause()
                        audioPlayer.audioPlayer?.currentTime = progress
                    }
                )
                
                if #available(iOS 15.0, *) {
                    TimelineView(.periodic(from: .now, by: 1/rate)){ _ in
                        HStack{
                            Text(formatTime(time: audioPlayer.audioPlayer?.currentTime))
                                .padding(.horizontal)
                                .foregroundStyle(isEditTime ? .red : .blue)
                                .onReceive(timer, perform: { _ in
                                    progress = audioPlayer.audioPlayer?.currentTime ?? 0
                                    relTime = progress/duration
                                    if autoCont && audioPlayer.finish && !hasContinue {
                                        self.go_next()
                                        hasContinue = true
                                    }
                                })
                            Spacer()
                            Text(formatTime(time: audioPlayer.audioPlayer?.duration))
                                .padding(.horizontal)
                                .foregroundStyle(.blue)
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
                
                HStack{
                    if let prev = prev{
                        prev
                    }
                    
                    Spacer()
                    
                    Button(action : {
                        if audioPlayer.isPlaying{
                            audioPlayer.pause()
                        } else {
                            audioPlayer.play()
                        }
                    }, label: {
                        Image(systemName: audioPlayer.isPlaying ? "pause" : "play")
                            .font(.largeTitle)
                            .padding(.bottom)
                    })
                    
                    Spacer()
                    
                    if let next = next {
                        next
                    }
                }

                Slider(value: $volume, in : 0...1, step: 0.01,
                       onEditingChanged: {edit in
                    isEditVol = edit
                    audioPlayer.audioPlayer?.volume = volume
                }).padding(.horizontal)
                
                HStack{
                    Spacer()
                    if #available(iOS 17.0, *) {
                        Text(String(format: "Volume: %.2f", volume))
                            .foregroundStyle(isEditVol ? .red : .blue)
                    } else {
                        // Fallback on earlier versions
                    }
                    Spacer()
                }
                
                Slider(value: $speed, in : 0.25...2, step: 0.01, onEditingChanged: {edit in
                    isEditSpeed = edit
                    audioPlayer.audioPlayer?.rate = speed
                }).padding(.horizontal)
                
                HStack{
                    Spacer()
                    if #available(iOS 17.0, *) {
                        Text(String(format: "Speed: %.2f", speed))
                            .foregroundStyle(isEditSpeed ? .red : .blue)
                    } else {
                        // Fallback on earlier versions
                    }
                    Spacer()
                }
                if #available(iOS 15.0, *) {
                    if #available(iOS 17.0, *) {
                        Toggle("Repeat", isOn: $autoRepeat).padding(.horizontal)
                            .foregroundStyle(.blue)
                            .onChange(of: autoRepeat){oldValue, newValue in
                                audioPlayer.autoRep = newValue
                                if autoRepeat{
                                    autoCont = false
                                    changer = false
                                }
                            }
                        
                        if !inRecord{
                            HStack{
                                Text("Auto Continue")
                                    .padding(.horizontal)
                                    .foregroundStyle(.blue)
                                    .padding(.vertical)
                                
                                Spacer()
                                
                                Button(action : {autoCont.toggle()
                                    changer.toggle()
                                    if autoCont{
                                        autoRepeat = false
                                    }
                                }){
                                    Image(systemName: changer ? "star.fill" : "star")
                                        .font(.title)
                                }.padding([.vertical, .trailing])
                            }
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                } else {
                    // Fallback on earlier versions
                }
                
                if inRecord {
                    Button("Copy Audio"){
                        copyItem()
                        rec.save()
                        isAlert = true
                    }
                    .padding(.vertical)
                    .alert(isPresented: $isAlert){ // This is the alert for the copy action
                        Alert(title: Text("COPY SUCCESSFUL"),
                              message: Text(title+" copied successfully")
                        )
                    }
                    
                    
                    Button("Delete Recording") {
                        // This just brings up the confirmation alert
                        isShowingDeleteAlert = true
                    }
                    .foregroundColor(.red) // Styled to indicate a destructive action
                    .padding(.top, 5)   // Adds a little space from the button above
                }
            }
            .alert(isPresented: $isShowingDeleteAlert) {
                Alert(
                    title: Text("Delete Recording"),
                    message: Text("Are you sure you want to permanently delete \(title)?"),
                    primaryButton: .destructive(Text("Delete")) {
                        // The actual deletion happens here
                        deleteRecording()
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear{
                audioPlayer.url = getURL()
                audioPlayer.make()
                changer = autoCont
                if let dur = audioPlayer.audioPlayer?.duration {self.duration = dur}
                if autoCont {audioPlayer.play()}
            }
            .onDisappear{
                audioPlayer.audioPlayer?.stop()
            }
        }
    }
}
