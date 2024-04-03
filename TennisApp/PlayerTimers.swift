//
//  PlayerTimers.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

let DOUBLES_PAIR_COUNT = 2
let ROUND_DEFAULT_TIME = 1 * 5

class StopwatchViewModel: ObservableObject {
    @Published var elapsedPlayerTime = 0
    @Published var elapsedRoundTime = 0
    @Published var isRunning = false
    @Published  var timePerRound: Int

    private var timer: Timer?
    
    init(timePerRound: Int) {
        self.timePerRound = timePerRound
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedPlayerTime += 1
            self.elapsedRoundTime += 1
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
        elapsedPlayerTime = 0
        isRunning = false
    }
    
    func resetRound() {
        elapsedRoundTime = 0
    }

}

struct PlayerItem: Identifiable {
    var id = UUID()
    var textFieldText: String
    var activePlayer: Bool
    
    init() {
        self.textFieldText = ""
        self.activePlayer = false
    }
    
}

struct DoublesRecord: Identifiable {
    var id = UUID()
    var player1Name: String
    var player2Name: String
    var timeSpentOnHill: Int
    var isRoundEndingTeam: Bool
    
    init(player1Name: String, 
         player2Name: String ,
         timeSpentOnHill: Int,
         isRoundEndingTeam: Bool){
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.timeSpentOnHill = timeSpentOnHill
        self.isRoundEndingTeam = isRoundEndingTeam
        
    }
}

struct PlayerTimers: View {
    @Binding var selectedTennisClass: String
    @Binding var numPlayers : Int
    @Binding var timePerRound: Int
    
    @StateObject var stopwatchViewModel : StopwatchViewModel
    @State private var playerRows: [PlayerItem]
    @State private var isTimerExpired = false
    @State private var roundCount = 1
    @State private var roundScoresList: [[DoublesRecord]] = []

    init(selectedTennisClass: Binding<String>,
         numPlayers: Binding<Int>,
         timePerRound: Binding<Int>)
    {
        _selectedTennisClass = selectedTennisClass
        _numPlayers = numPlayers
        _timePerRound = timePerRound
        
        _stopwatchViewModel = StateObject(wrappedValue: StopwatchViewModel(timePerRound: timePerRound.wrappedValue))

        _playerRows = State(initialValue: (0..<numPlayers.wrappedValue).map{
                _ in PlayerItem()
            } )

    }
       
    
    
    @State private var doublesRecordList : [DoublesRecord] = [
         //Debug Double Records for formatting. Uncomment to use.
        DoublesRecord(player1Name: "fea 1", player2Name: "Playberabreaevwar 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
        DoublesRecord(player1Name: "be 1", player2Name: "Pbfdlar 2", timeSpentOnHill: 4, isRoundEndingTeam: false),
        /*
        DoublesRecord(player1Name: "Player 1", player2Name: "Placyer 2", timeSpentOnHill: 2, isRoundEndingTeam: false),
        DoublesRecord(player1Name: "Playebbzr 1", player2Name: "Plabdayer 2", timeSpentOnHill: 1, isRoundEndingTeam: true)
        */
    ]
    @State private var playerSelectCount = 0;
    
    var body: some View {
        // Timer Section
        // Optional Debug Text for Options Listed
//        Text("Selected option: \(selectedTennisClass) \(numPlayers)")
//            .padding()
        VStack {
            HStack {
                Text("Time Left in Round: ")
                    .font(.title3)

                     
                Text("\(String(format: "%dm %ds", (ROUND_DEFAULT_TIME - stopwatchViewModel.elapsedRoundTime)/60, (ROUND_DEFAULT_TIME - stopwatchViewModel.elapsedRoundTime) % 60))")
                    .font(.title3)

            }
            .onReceive(stopwatchViewModel.$elapsedRoundTime) { newValue in
                if newValue >= stopwatchViewModel.timePerRound {
                    roundOverCleanUp()
                }
            }

            HStack {
                Text("Current Live Ball Champ: \(String(format: "%ds", stopwatchViewModel.elapsedPlayerTime))")
                    .font(.title3)
                /* //Optional Debug Stopwatch Buttons
                HStack {
                    Button(action: {
                        if stopwatchViewModel.isRunning {
                            stopwatchViewModel.stop()
                        } else {
                            stopwatchViewModel.start()
                        }
                    }) {
                        Text(stopwatchViewModel.isRunning ? "Stop" : "Start")
                        .padding(3)
                    }
                    
                    Button(action: {
                        stopwatchViewModel.reset()
                    }) {
                        Text("Reset")
                        .padding(3)
                    }
                }
                 */

            }

        }
        
        // Player Card Section
        VStack() {
            List(playerRows) { PlayerItem in
                HStack {
                    TextField("Enter text", text: self.binding(for: PlayerItem))
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 10)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        // Change color logic here
                        self.toggleActivePlayer(for: PlayerItem)
                        
                    }) {
                        Image(systemName: buttonSymbol(for: PlayerItem))
                            .padding()
                            .background(buttonColor(for: PlayerItem))
                            .foregroundColor(.white)
                        
                    }
                    .padding(.trailing)
                    .frame(height: 10)

                }
            }
        }
        .frame(height: 475)
        
        
        // Doubles History Section
        NavigationView {
            ZStack() {
                ScrollView {
                    VStack {
                        ForEach(0..<doublesRecordList.count, id: \.self) {index in
                            HStack {
                                if doublesRecordList[index].isRoundEndingTeam {
                                    Image(systemName: "crown.fill")
                                        .frame(width: 30) // Set explicit size for the crown icon
                                } else {
                                    Spacer().frame(width: 30) // Spacer to maintain alignment when no crown icon is present
                                }
                                
                                Text("\(doublesRecordList[index].player1Name)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1) // Limit to one line

                                
                                Text("\(doublesRecordList[index].player2Name)")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .lineLimit(1) // Limit to one line

                                
                                Text(String(format: "%ds", doublesRecordList[index].timeSpentOnHill))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 30)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .background(Color.black)
                .foregroundColor(Color.white)
                
                // End Round/Session/ Clear Doubles Table Buttons
                HStack {
                    if !doublesRecordList.isEmpty {
                        
                        Button(action: {
                            // Change color logic here
                            self.endRound()
                            
                        }) {
                            Text("End Round")
                                .padding()
                                .foregroundColor(Color.black)
                                .background(Color.white)
                                .opacity(0.5)
                                .frame(alignment: .bottom)
                        }
                        Button(action: {
                            // Change color logic here
                            self.resetDoublesRecord()
                            
                        }) {
                            Text("Clear")
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .opacity(0.5)
                            .frame(alignment: .bottom)
                        }

                    }
                    NavigationLink(destination: doublesRecordList.count >= 1 ? SubmitPlayerScores() : nil) {
                        Text("End Session")
                    }
                    .padding()
                    .foregroundColor(Color.black)
                    .background(Color.white)
                    .opacity(0.5)
                    .frame(alignment: .bottom)
                    
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
            playerRows[index].activePlayer.toggle()
            playerSelectCount += playerRows[index].activePlayer ? 1 : -1

        } else if (stopwatchViewModel.isRunning) {
            liveBallGameState()

        } else {
            playerRows[index].activePlayer.toggle()
            playerSelectCount += playerRows[index].activePlayer ? 1 : -1
        }

        liveBallGameState()



    }
    
    
    // Toggling Logic for the color. Selects which color based on that PlayerItem's active Status
    private func buttonColor(for PlayerItem: PlayerItem) -> Color {
        guard let index = playerRows.firstIndex(where: { $0.id == PlayerItem.id }) else {
            return .blue
        }
        return playerRows[index].activePlayer ? .red : .blue
    }
    
    private func buttonSymbol(for PlayerItem: PlayerItem) -> String {
        guard let index = playerRows.firstIndex(where: { $0.id == PlayerItem.id }) else {
            return "crown.fill"
        }
        return playerRows[index].activePlayer ? "crown.fill" : "crown"

    }
    private func liveBallGameState() {
        // Minimum amount of players selected should exit out and not trigger reset logic
        
        if playerSelectCount >= 2 && !stopwatchViewModel.isRunning {
            stopwatchViewModel.start()
        } else if playerSelectCount >= 2 && stopwatchViewModel.isRunning {
            stopwatchViewModel.stop()
            addDoublesRecord(endOfRound: false)
            resetAllActivePlayers()
            stopwatchViewModel.reset()
        }

    }
    
    private func addDoublesRecord(endOfRound: Bool){
        var activePlayers : [String] = []
        for index in playerRows.indices {
            if playerRows[index].activePlayer{
                activePlayers.append(playerRows[index].textFieldText)
            }
        }
        
        doublesRecordList.append(DoublesRecord(
            player1Name: activePlayers[0],
            player2Name: activePlayers[1],
            timeSpentOnHill: stopwatchViewModel.elapsedPlayerTime,
            isRoundEndingTeam: endOfRound
        ))
        
        doublesRecordList.sort {$0.timeSpentOnHill > $1.timeSpentOnHill}
    }
    
    private func resetAllActivePlayers() {
        for index in playerRows.indices {
            playerRows[index].activePlayer = false
        }
        playerSelectCount = 0
    }
    
    private func resetDoublesRecord() {
        doublesRecordList = []
    }
    
    private func roundOverCleanUp() {
        stopwatchViewModel.stop()
        addDoublesRecord(endOfRound: true)
        resetAllActivePlayers()
        stopwatchViewModel.reset()
        print("Clean Up!")

    }
    
    private func endRound() {
        roundScoresList.append(doublesRecordList)
        resetDoublesRecord()
        stopwatchViewModel.resetRound()
        print(roundScoresList)
        
    }
    
    
}

#Preview {
    PlayerTimers(
        selectedTennisClass: .constant("Option A"),
        numPlayers: .constant(10),
        timePerRound: .constant(ROUND_DEFAULT_TIME)
    )
}


