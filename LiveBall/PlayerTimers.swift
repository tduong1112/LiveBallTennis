//
//  PlayerTimers.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

let DOUBLES_PAIR_COUNT = 2
let ROUND_DEFAULT_PREVIEW_TIME = 10
let SECONDS_PER_MINUTE = 60

class StopwatchViewModel: ObservableObject {
    @Published var elapsedPlayerTime = 0
    @Published var elapsedRoundTime = 0
    @Published var isRunning = false
    @Published  var timePerRound: Int

    private var timer: Timer?
    
    init(timePerRound: Int) {
        self.timePerRound = timePerRound * SECONDS_PER_MINUTE
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
    var activePlayer: Bool
    var playerName: String
    
    init(playerName: String) {
        self.playerName = playerName
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
    @Binding var playerNames : [String]
    @Binding var timePerRound: Int
    
    @StateObject var stopwatchViewModel : StopwatchViewModel
    @State private var playerRows: [PlayerItem]

    @State private var showingErrorAlert = false
    @State private var isTimerExpired = false
    @State private var roundCount = 1
    @State private var roundScoresList: [[DoublesRecord]] = []
    @State private var playerSelectCount = 0;
    @State private var doublesRecordList : [DoublesRecord] = [
         //Debug Double Records for formatting. Uncomment to use.
        /*

        DoublesRecord(player1Name: "fea 1", player2Name: "Playberabreaevwar 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
        DoublesRecord(player1Name: "be 1", player2Name: "Pbfdlar 2", timeSpentOnHill: 4, isRoundEndingTeam: false),
        DoublesRecord(player1Name: "Player 1", player2Name: "Placyer 2", timeSpentOnHill: 2, isRoundEndingTeam: false),
        DoublesRecord(player1Name: "Playebbzr 1", player2Name: "Plabdayer 2", timeSpentOnHill: 1, isRoundEndingTeam: true)
        */
    ]
    let columns = [
        GridItem(.fixed(100)),
        GridItem(.fixed(100)),
        GridItem(.fixed(100))
    ]
    

    init(playerNames: Binding<[String]>,
         timePerRound: Binding<Int>)
    {
        _playerNames = playerNames
        _timePerRound = timePerRound
        _stopwatchViewModel = StateObject(wrappedValue: StopwatchViewModel(timePerRound: timePerRound.wrappedValue))

        playerRows = playerNames.wrappedValue.map { PlayerItem(playerName: $0) }


    }
       
    var body: some View {
        // Timer Section
        // Optional Debug Text for Options Listed
//        Text("Selected option: \(selectedTennisClass) \(numPlayers)")
//            .padding()
        VStack{
            VStack{
                HStack {
                    Text("Time Left in Round: ")
                        .font(.title3)
                    
                    
                    Text("\(String(format: "%dm %ds", (stopwatchViewModel.timePerRound - stopwatchViewModel.elapsedRoundTime)/60, (stopwatchViewModel.timePerRound - stopwatchViewModel.elapsedRoundTime) % 60))")
                        .font(.title3)
                    
                }
                .onReceive(stopwatchViewModel.$elapsedRoundTime) { newValue in
                    if newValue >= stopwatchViewModel.timePerRound {
                        roundOverCleanUp()
                    }
                }
                
                HStack {
                    Text("Current Live Ball Champ: \(String(format: "%dm %ds", stopwatchViewModel.elapsedPlayerTime/60, stopwatchViewModel.elapsedPlayerTime % 60))")
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
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(playerRows, id: \.id) { player in
                        Button(action: {
                            // Handle button tap action here
                            self.toggleActivePlayer(for: player)
                        }) {
                            Text(player.playerName)
                                .padding()
                                .frame(width: 100, height: 100) // Set fixed size for each button
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .background(buttonColor(for: player))
                        }
                        .buttonStyle(PlainButtonStyle()) // Remove default button styling
                        
                    }
                }
                .padding()
            }
        
        
            // Doubles History Section
            
            VStack() {
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
                                    
                                    
                                    Text(String(format: "%dm %ds", doublesRecordList[index].timeSpentOnHill/60, doublesRecordList[index].timeSpentOnHill % 60))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.trailing, 30)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
                    .background(Color.black)
                    .foregroundColor(Color.white)
                    
                    
                }
                // End Round/Session/ Clear Doubles Table Buttons
                HStack {
                    if !doublesRecordList.isEmpty {
                        
                        Button(action: {
                            // Change color logic here
                            self.endRound()
                            
                        }) {
                            Text("End Round")
                        }
                        .buttonStyle(.borderedProminent)
                        
                    }
                    if roundScoresList.count >= 1 {
                        NavigationLink(destination: SubmitPlayerScores(roundScoresList: $roundScoresList)) {
                            Text("End Session")
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(action: {
                            // Display error message here
                            self.showingErrorAlert = true
                        }) {
                            Text("End Session")
                        }
                        .buttonStyle(.borderedProminent)
                        .alert(isPresented: $showingErrorAlert) {
                            Alert(title: Text("Error"), message: Text("No rounds recorded. Cannot end session."), dismissButton: .default(Text("OK")))
                        }
                    }
                }
            }
        }
    }
    
    private func toggleActivePlayer(for playerItem: PlayerItem) {
        guard let index = playerRows.firstIndex(where: { $0.id == playerItem.id }) else {
            return
        }
        
        if !playerRows[index].activePlayer && !stopwatchViewModel.isRunning {
            playerRows[index].activePlayer.toggle()
            playerSelectCount += playerRows[index].activePlayer ? 1 : -1
        }

        if !playerRows[index].activePlayer && stopwatchViewModel.isRunning {
            handleTimerStopped(for: index)
        }
        if playerSelectCount >= 2 && !stopwatchViewModel.isRunning {
            stopwatchViewModel.start()
        }
    }

    private func handleTimerStopped(for index: Int) {
        stopwatchViewModel.stop()
        addDoublesRecord(endOfRound: false)
        stopwatchViewModel.reset()
        resetAllActivePlayers()
        playerRows[index].activePlayer.toggle()
        playerSelectCount += playerRows[index].activePlayer ? 1 : -1
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


    
    private func addDoublesRecord(endOfRound: Bool){
        var activePlayers : [String] = []
        
        for index in playerRows.indices {
            if playerRows[index].activePlayer{
                activePlayers.append(playerRows[index].playerName)
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
        playerNames: .constant(["asdf", "bweaewaveaveaw", "graphic", 
                                "manny", "who that", "feafe",
                                "player1", "Player2", "feafe",
                                "bweaewaveaveaw", "who that", "feafe",
                                "manny", "who that", "feafe"]),
        timePerRound: .constant(ROUND_DEFAULT_PREVIEW_TIME)
    )
}


