//
//  PlayerTimers.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

let DOUBLES_PAIR_COUNT = 2


class StopwatchViewModel: ObservableObject {
    @Published var elapsedTime = 0.0
    @Published var isRunning = false
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime += 0.01
        }
        isRunning = true
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0.0
        isRunning = false
    }
}

struct PlayerItem: Identifiable {
    var id = UUID()
    var textFieldText: String
    var activePlayer: Bool
    
    init(count: Int) {
        self.textFieldText = "Player \(count)"
        self.activePlayer = false
    }

}

struct PlayerTimers: View {
    @Binding var selectedTennisClass: String
    @Binding var numPlayers : Int
    @StateObject var stopwatchViewModel = StopwatchViewModel()
    
    @State private var playerRows: [PlayerItem] = {
        var array = [PlayerItem]()
        for count in 0..<5 {
            array.append(PlayerItem(count: count))
        }
        return array
    }()
    
    @State private var playerSelectCount = 0;
    @State private var gameStateEnum = 0;
    
    var body: some View {
        
        Text("Selected option: \(selectedTennisClass) \(numPlayers)")
        Text(String(format: "%.2f", stopwatchViewModel.elapsedTime))
        
        HStack {
            Button(action: {
                if stopwatchViewModel.isRunning {
                    stopwatchViewModel.stop()
                } else {
                    stopwatchViewModel.start()
                }
            }) {
                Text(stopwatchViewModel.isRunning ? "Stop" : "Start")
                    .padding()
            }
            
            Button(action: {
                stopwatchViewModel.reset()
            }) {
                Text("Reset")
                    .padding()
            }
        }
    

        VStack {
            List(playerRows) { PlayerItem in
                HStack {
                    TextField("Enter text", text: self.binding(for: PlayerItem))
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        // Change color logic here
                        self.toggleActivePlayer(for: PlayerItem)

                    }) {
                        Text("\(PlayerItem.activePlayer)")
                            .padding()
                            .background(buttonColor(for: PlayerItem))
                            .foregroundColor(.white)
                            .cornerRadius(2)

                    }
                    .padding(.trailing)
                }
            }
        }


    }
    private func binding(for PlayerItem: PlayerItem) -> Binding<String> {
        guard let index = playerRows.firstIndex(where: { $0.id == PlayerItem.id }) else {
            fatalError("Can't find PlayerItem in array")
        }
        return $playerRows[index].textFieldText
    }
    
    private func toggleActivePlayer(for PlayerItem: PlayerItem) {
        guard let index = playerRows.firstIndex(where: { $0.id == PlayerItem.id }) else {
            return
        }
        // Make sure an empty name is not submitted
        if playerRows[index].textFieldText.isEmpty{
            return
        }
        playerRows[index].activePlayer.toggle()
        
        // State Logic for Player Count Activating Timer
        playerSelectCount += playerRows[index].activePlayer ? 1 : -1
        
        liveBallGameState()
    }
    
    
    // Toggling Logic for the color. Selects which color based on that PlayerItem's active Status
    private func buttonColor(for PlayerItem: PlayerItem) -> Color {
        guard let index = playerRows.firstIndex(where: { $0.id == PlayerItem.id }) else {
            return .blue
        }
        return playerRows[index].activePlayer ? .red : .blue
    }
    
    private func liveBallGameState() {
        if playerSelectCount >= 2 && !stopwatchViewModel.isRunning {
            stopwatchViewModel.start()
        } else if stopwatchViewModel.isRunning {
            stopwatchViewModel.stop()
            resetAllActivePlayers()
        }
    }
    
    private func resetAllActivePlayers() {
        for index in playerRows.indices {
            playerRows[index].activePlayer = false
        }
        playerSelectCount = 0
    }

    
}

#Preview {
    PlayerTimers(
        selectedTennisClass: .constant("Option A"),
        numPlayers: .constant(5)
    )
}
        

