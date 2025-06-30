//
//  RenameView.swift
//  Audio Recorder
//
//  Created by Jonathan Tjandra on 8/17/24.
//  Copyright © 2024 Balaji. All rights reserved.
//

import SwiftUI



struct Ind : Identifiable {
    let id = UUID()
    var ind : Int
}

struct RenameView: View {
    
    @StateObject var rec = ar
    
    @State var curName : [String] = []
    
    @State var count : [Ind] = []
    
    @State private var showAlert = false
    
    var validName : Bool {
        get {
            for name in curName {
                if name == ""{
                    return false
                }
            }
            return true
        }
    }
    
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                ZStack{
                        LinearGradient.linearGradient(colors: [.indigo, .yellow], startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea()
                            .opacity(0.9)
                        
                        VStack{
                            
                            
                                List{
                                    
                                    Section(header : Text("Audio Names")
                                        .textCase(nil)
                                        .font(.title2)
                                        .foregroundStyle(.orange)
                                            
                                    ){
                                        ForEach(count){ind in
                                            
                                            
                                            
                                            if #available(iOS 17.0, *) {
                                                TextField("Enter Name", text: $curName[ind.ind])
                                                    .onChange(of : curName){old, new in
                                                        
                                                        ar.audiosTitle[ind.ind] = curName[ind.ind]
                                                        rec.save()
                                                        
                                                    }
                                                
                                            } else {
                                                // Fallback on earlier versions
                                            }
                                            
                                        }
                                    }
                                }.scrollContentBackground(.hidden)
                        
                                
                                NavigationLink(destination: RecordView().navigationBarBackButtonHidden(true),
                                               label: {
                                    Image(systemName: "house")
                                        .padding()
                                        .bold()
                                        .foregroundStyle(.blue)
                                        .font(.title)
                                })
                                .disabled(!validName)
                                .onTapGesture {
                                    if !validName {
                                        showAlert = true
                                    }
                                }
                                .alert(isPresented: $showAlert) {
                                Alert(title: Text("Invalid Name"), 
                                      message: Text("Name cannot be empty")
                                )
                            }
                                
                                
                       
                            
                            
                        }.onAppear{
                            curName = ar.audiosTitle
                            count = []
                            for (ind, _) in curName.enumerated(){
                                count.append(Ind(ind: ind))
                            }
                            
                        }
                  
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    RenameView()
}
