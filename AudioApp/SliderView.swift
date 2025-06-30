//
//  SliderView.swift
//  Audio Recorder
//
//  Created by Jonathan Tjandra on 8/12/24.
//  Copyright © 2024 Balaji. All rights reserved.
//

import AVFoundation
import SwiftUI

struct SliderView : View{
        @Binding var progress : TimeInterval
        @Binding var max : TimeInterval
        var f : (Bool) -> ()
        
        var body : some View {
            Slider(value: $progress, in: 0...max, onEditingChanged: f).padding(.horizontal)
        }
    }
