//
//  TestNav.swift
//  Audio Recorder
//
//  Created by Jonathan Tjandra on 8/13/24.
//  Copyright © 2024 Balaji. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation


struct MyAudioFormat : Identifiable{
    let id = UUID()
    var ind : Int
    var name : String
    var ext : String
    var title : String
}

struct RecordingFormat : Identifiable {
    let id = UUID()
    var ind : Int
    var url : URL
    var title : String
}



struct HearView: View {
    
    @StateObject var rec = ar
  
    @State var autoCon = autoCont
    @State var myAudios : [MyAudioFormat] = [
        MyAudioFormat(ind: 0, name: "audio", ext: "mp3", title: "Test Audio 1"),
        MyAudioFormat(ind: 1, name: "audio-2", ext: "mp3", title: "Test Audio 2")
    ]
    
    @State var index : [Int] = []

    
    func mod(_ num : Int)->Int{
        if num >= 0 && num < (myAudios.count + rec.formatAudio.count){return num}
        if num == -1 {return myAudios.count + rec.formatAudio.count - 1}
        return 0
    }
    
    var body: some View {
        
        VStack{
        if #available(iOS 16.0, *) {
            NavigationStack(path: $index){
                
                List{
                    Section(header : Text("Song")
                        .font(.title2)
                        .foregroundStyle(.orange)
                            
                    ){
                        ForEach(myAudios){
                            elm in
                            NavigationLink(value: elm.ind){Text(elm.title)}
                        }
                        
                        
                    }
                    
                    Section(header : Text("Recording")
                        .font(.title2)
                        .foregroundStyle(.orange)
                            
                    ){
                        ForEach(rec.formatAudio){
                            elm in
                            NavigationLink(value: elm.ind + myAudios.count){Text(elm.title)}
                        }
                        
                        
                    }
                    
                    
                    
                }.navigationTitle("All Audio")
                    .scrollContentBackground(.hidden)
                    .background(.linearGradient(colors: [.indigo, .yellow], startPoint: .top, endPoint: .bottom).opacity(0.9))
                    .navigationDestination(for: Int.self){elm in
                        
                        if mod(elm) < myAudios.count {
                            PlayView(file: myAudios[mod(elm)].name,
                                     myAudios[mod(elm)].ext,
                                     title: myAudios[mod(elm)].title,
                                     prev: Prev(arr: $index, ind: mod(elm)),
                                     next : Next(arr: $index, ind: mod(elm))
                            )
                            .navigationBarBackButtonHidden(true)
                            .toolbar{
                                ToolbarItem(placement: .bottomBar){
                                    Button(action:{
                                        autoCont = false
                                        index = []
                                    }){
                                        Image(systemName: "house")
                                            .padding()
                                            .bold()
                                            .foregroundStyle(.blue)
                                            .font(.title)
                                    }
                                }
                            }
                            
                        }
                        
                        else {
                            PlayView(url: rec.formatAudio[mod(elm) - myAudios.count].url,
                                     title: rec.formatAudio[mod(elm) - myAudios.count].title,
                                     prev: Prev(arr: $index, ind: mod(elm)),
                                     next : Next(arr: $index, ind: mod(elm))
                            ).navigationBarBackButtonHidden(true)
                                .toolbar{
                                    ToolbarItem(placement: .bottomBar){
                                        Button(action:{
                                            autoCont = false
                                            index = []
                                        }){
                                            Image(systemName: "house")
                                                .padding()
                                                .bold()
                                                .foregroundStyle(.blue)
                                                .font(.title)
                                        }
                                    }
                                }
                        }
                    }
                
                
            }
        } else {
            // Fallback on earlier versions
        }
        
        
        }
       
            
        }
    }
#Preview{
    HearView()
}
