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
            self.elapsedTime += 0.1
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

struct DoublesRecord: Identifiable {
    var id = UUID()
    var player1Name: String
    var player2Name: String
    var timeSpentOnHill: Double
    
    init(player1Name: String, player2Name: String , timeSpentOnHill: Double){
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.timeSpentOnHill = timeSpentOnHill
        
    }
}

struct PlayerTimers: View {
    @Binding var selectedTennisClass: String
    @Binding var numPlayers : Int
    @StateObject var stopwatchViewModel = StopwatchViewModel()
    
    @State private var playerRows: [PlayerItem] = {
        var array = [PlayerItem]()
        for count in 0..<10 {
            array.append(PlayerItem(count: count))
        }
        return array
    }()
    
    
    @State private var doublesRecordList : [DoublesRecord] = [
    ]
    @State private var playerSelectCount = 0;
    
    var body: some View {
        // Timer Section
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
        
        // Player Card Section
        VStack(spacing: 3) {
            List(playerRows) { PlayerItem in
                HStack {
                    TextField("Enter text", text: self.binding(for: PlayerItem))
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 10)

                    
                    Button(action: {
                        // Change color logic here
                        self.toggleActivePlayer(for: PlayerItem)
                        
                    }) {
                        Text("\(PlayerItem.activePlayer)")
                            .padding()
                            .background(buttonColor(for: PlayerItem))
                            .foregroundColor(.white)
                        
                    }
                    .padding(.trailing)
                    .frame(height: 10)

                }
            }
        }
        .frame(height: 500)
        
        
        // Doubles History Section
        ScrollView {
            VStack (spacing: 1){
                ForEach(0..<doublesRecordList.count, id: \.self) {index in
                    HStack {
                        Text("\(doublesRecordList[index].player1Name)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)

                        Text("\(doublesRecordList[index].player2Name)")
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(String(format: "%.2f", doublesRecordList[index].timeSpentOnHill))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 60)
                    }
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
        if (playerRows[index].activePlayer && stopwatchViewModel.isRunning ){
            stopwatchViewModel.stop()
            stopwatchViewModel.reset()
        }
        playerRows[index].activePlayer.toggle()
        
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
        // Minimum amount of players selected should exit out and not trigger reset logic

        if playerSelectCount >= 2 && !stopwatchViewModel.isRunning {
            stopwatchViewModel.start()
        } else if playerSelectCount >= 2 && stopwatchViewModel.isRunning {
            stopwatchViewModel.stop()
            addDoublesRecord()
            resetAllActivePlayers()
            stopwatchViewModel.reset()
        }

    }
    
    private func addDoublesRecord(){
        var activePlayers : [String] = []
        for index in playerRows.indices {
            if playerRows[index].activePlayer{
                activePlayers.append(playerRows[index].textFieldText)
            }
        }
        
        doublesRecordList.append(DoublesRecord(
            player1Name: activePlayers[0],
            player2Name: activePlayers[1],
            timeSpentOnHill: stopwatchViewModel.elapsedTime))

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
        numPlayers: .constant(10)
    )
}


