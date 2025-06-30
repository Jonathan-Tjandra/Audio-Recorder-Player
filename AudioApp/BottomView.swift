//
//  BottomView.swift
//  Audio Recorder
//
//  Created by Jonathan Tjandra on 8/13/24.
//  Copyright © 2024 Balaji. All rights reserved.
//

import SwiftUI


struct Prev : View {
        @Binding var arr : [Int]
        var ind : Int
    
    func go_prev(){ arr.append(ind - 1)}
       
        var body: some View {
            Button(action: {
               
               go_prev()

            }){
                HStack{
                    Image(systemName: "chevron.left")
                        .padding(.leading)
                    Text("Prev")
                }
            }
        }
    }
    
struct Next : View {
        @Binding var arr : [Int]
        var ind : Int
    
    func go_next(){ arr.append(ind + 1)}
        var body: some View {
            Button(action: {
               
               go_next()

            }){
                HStack{
                    Text("Next")
                    Image(systemName: "chevron.right")
                        .padding(.trailing)
                    
                }
            }
            
        }
    }
    
    
