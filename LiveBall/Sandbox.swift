//
//  Sandbox.swift
//  TennisApp
//
//  Created by Yee on 4/1/24.
//

import SwiftUI
import AVFoundation

class SillyClass: ObservableObject {
    @Published var elapsedTime = 0.0
    @Published var isRunning = false
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime += 0.1
        }
        isRunning = true
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}

struct MyStruct: Identifiable {
    var id = UUID()
    @StateObject var TimerClass: SillyClass
}
struct Sandbox: View {
    var audioPlayer: AVAudioPlayer?

    init() {
         // Initialize the audio player with the sound file
         if let soundURL = Bundle.main.url(forResource: "your_sound_file", withExtension: "mp3") {
             do {
                 audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
             } catch {
                 print("Error loading sound file: \(error.localizedDescription)")
             }
         }
     }

    var body: some View {
        Button(action: {
            // Handle button tap action here
            self.playAudio()
        }) {
            Text("Play SOund")
        }
    }
    
    private func playAudio() {
        if let audioPlayer = audioPlayer {
            audioPlayer.play()
        }
    }
}

#Preview {
    Sandbox()
}
