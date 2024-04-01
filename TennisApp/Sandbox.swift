//
//  Sandbox.swift
//  TennisApp
//
//  Created by Yee on 4/1/24.
//

import SwiftUI
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

    @State private var rows: [RowItem] = {
        var array = [RowItem]()
        for _ in 0..<5 {
            array.append(RowItem())
        }
        return array
    }()

    @State private var currentDate = Date.now
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text("\(currentDate)")
            .onReceive(timer) { input in
                currentDate = input
            }
    }
}

#Preview {
    Sandbox()
}
