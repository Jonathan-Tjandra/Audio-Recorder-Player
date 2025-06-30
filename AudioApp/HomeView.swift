//
//  HomeView.swift
//  Audio Recorder
//
//  Created by Jonathan Tjandra on 8/12/24.
//  Copyright © 2024 Balaji. All rights reserved.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView{
            Group{
                if #available(iOS 14.0, *) {
                    RecordView()
                        .tabItem{
                            if #available(iOS 14.0, *) {
                                Label("Record", systemImage: "record.circle")
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                } else {
                    // Fallback on earlier versions
                }
                HearView()
                    .tabItem {
                        if #available(iOS 14.0, *) {
                            Label("Play", systemImage: "play")
                        } else {
                            // Fallback on earlier versions
                        }
                    }
               
            }

            
           
        }
    }
}

#Preview {
    HomeView()
}
