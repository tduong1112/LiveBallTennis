//
//  Sandbox.swift
//  TennisApp
//
//  Created by Yee on 4/1/24.
//

import SwiftUI
import AVKit



struct Sandbox: View {
    var body: some View {
        Button("Play Sound 1") {
            SoundManager.instance.playSound()
        }
    }
}

#Preview {
    Sandbox()
}
