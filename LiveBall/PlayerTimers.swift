//
//  PlayerTimers.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI
import AVFoundation

let DOUBLES_PAIR_COUNT = 2
let ROUND_DEFAULT_PREVIEW_TIME = 2
let SECONDS_PER_MINUTE = 60
let WARNING_TIME_SECONDS = SECONDS_PER_MINUTE * 1 + 30 // 1 minute 30 second warning time

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
        if self.elapsedRoundTime >= self.timePerRound {
            return
        }
        
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
    
    func resetPlayer() {
        elapsedPlayerTime = 0
    }
    
    func resetRound() {
        elapsedPlayerTime = 0
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

struct DoublesRecord: Codable {
    var player1Name: String
    var player2Name: String
    var timeSpentOnHill: Int
    var isRoundEndingTeam: Bool
    var round: Int

    init(player1Name: String, 
         player2Name: String ,
         timeSpentOnHill: Int,
         isRoundEndingTeam: Bool,
         round: Int){
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.timeSpentOnHill = timeSpentOnHill
        self.isRoundEndingTeam = isRoundEndingTeam
        self.round = round
        
    }
}

class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "iphone-alarm", withExtension: ".mp3") else {return}
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
    }
}

struct PlayerTimers: View {
    @Binding var playerNames : [String]
    @Binding var timePerRound: Int
    @Binding var selectedTennisClass: String
    
    @StateObject var stopwatchViewModel : StopwatchViewModel
    

    @State private var playerRows: [PlayerItem]
    
    @State private var showingErrorAlert = false
    @State private var roundTimerExpiredAlarm = false
    @State private var warningTimerExpiredAlarm = false
    @State private var roundEndScoreState = false

    @State private var roundCount = 1
    @State private var playerSelectCount = 0;

    @State private var roundScoresList: [[DoublesRecord]] = []
    @State private var championsSelected: [PlayerItem] = []
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
    var audioPlayer: AVAudioPlayer?

    
    
    init(playerNames: Binding<[String]>,
         timePerRound: Binding<Int>,
         selectedTennisClass: Binding<String>)
    {
        _playerNames = playerNames
        _timePerRound = timePerRound
        _selectedTennisClass = selectedTennisClass
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
                    if roundEndScoreState {
                        Text("Round Ended")
                            .font(.largeTitle)
                    } else {
                        Text("\(String(format: "%dm %ds", stopwatchViewModel.elapsedRoundTime/60, stopwatchViewModel.elapsedRoundTime % 60))")
                            .font(.largeTitle)
                            .foregroundColor(stopwatchViewModel.timePerRound - stopwatchViewModel.elapsedRoundTime > 10 ? .black : .red)
                        

                    }
                }
                .onReceive(stopwatchViewModel.$elapsedRoundTime) { newValue in
                    if newValue >= stopwatchViewModel.timePerRound && !roundTimerExpiredAlarm {
                        roundTimerExpiredAlarm = true
                        SoundManager.instance.playSound()
                        stopwatchViewModel.stop()
                    } else if WARNING_TIME_SECONDS > stopwatchViewModel.timePerRound && !warningTimerExpiredAlarm {
                        warningTimerExpiredAlarm = true // Avoid a case where timer is set to 1 minute and cause some weirdness
                    }
                    else if newValue >= (stopwatchViewModel.timePerRound - WARNING_TIME_SECONDS) && !warningTimerExpiredAlarm {
                        print("Warning Time Reached")
                        warningTimerExpiredAlarm = true
                    }
                }
                
                HStack {
                    Text("Current Live Ball Champ: \(String(format: "%dm %ds", stopwatchViewModel.elapsedPlayerTime/60, stopwatchViewModel.elapsedPlayerTime % 60))")
                        .font(.caption)
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
                     stopwatchViewModel.resetPlayer()
                     }) {
                     Text("Reset")
                     .padding(3)
                     }
                     }
                     */
                    
                }
            }
            
            // Player Card Section
            VStack {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    if championsSelected.count >= 2 {
                        ZStack {
                            // Red colored rectangle
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 150, height: 50)
                                .cornerRadius(10)
                            
                            // Text inside the rectangle
                            Text("\(self.championsSelected[0].playerName)")
                                .foregroundColor(.white)
                        }
                            
                        ZStack {
                            // Red colored rectangle
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 150, height: 50)
                                .cornerRadius(10)
                            
                            // Text inside the rectangle
                            Text("\(self.championsSelected[1].playerName)")
                                .foregroundColor(.white)
                        }
                    }
                }
            
            
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
                    if championsSelected.count >= DOUBLES_PAIR_COUNT && !roundTimerExpiredAlarm && !roundEndScoreState{
                        Button(action: {
                            // Change color logic here
                            if !roundEndScoreState {
                                stopwatchViewModel.isRunning  ? stopwatchViewModel.stop() : stopwatchViewModel.start()
                            }
                        }) {
                            Text(stopwatchViewModel.isRunning  ? "Pause" : "Resume")
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    
                    if roundEndScoreState {
                        Button(action: {
                            // Change color logic here
                            self.nextRound()
                            
                        }) {
                            Text("Start Next Round")
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(action: {
                            // Change color logic here
                            self.endRoundCleanUp()
                            
                        }) {
                            Text("End Round")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                        
                    
                    if roundScoresList.count >= 1 {
                        NavigationLink(destination: SessionReview(roundScoresList: $roundScoresList,
                                                                       selectedTennisClass: $selectedTennisClass)) {
                            Text("Session View")
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(action: {
                            // Display error message here
                            self.showingErrorAlert = true
                        }) {
                            Text("Session View")
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

        if roundEndScoreState {
            return
        }

        togglePlayerItem(idx: index)
        // Live Ball Timer states are event triggered by button presses.
        liveBallStateMachine(idx: index)
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

    private func togglePlayerItem(idx: Int) {
        playerRows[idx].activePlayer.toggle()
        playerSelectCount += playerRows[idx].activePlayer ? 1 : -1
    }
    
    
    private func liveBallStateMachine(idx: Int) {
        switch playerSelectCount {
            case 0...1:
                return
            case 2:

                if !stopwatchViewModel.isRunning {
                    addChampButtonView()
                    stopwatchViewModel.start()
                    return
                }
            case 3:
                addDoublesRecord(endOfRound: false)
                stopwatchViewModel.resetPlayer()
            case 4:
                returnChampsBackToPlayerList()
                addChampButtonView()
                playerSelectCount = 2
            default:
                print("Error reached Default")
            }
    }
    
    private func removeActivePlayers() {
        // Filter out the items where activePlayer is true
        let filteredPlayerRows = playerRows.filter { !$0.activePlayer }

        // Update the @State property with the filtered list
        playerRows = filteredPlayerRows
    }
    
    private func returnChampsBackToPlayerList() {
        if championsSelected.count < DOUBLES_PAIR_COUNT {
            return
        }
        championsSelected[0].activePlayer = false
        championsSelected[1].activePlayer = false

        playerRows.append(championsSelected[0])
        playerRows.append(championsSelected[1])
        championsSelected = []
    }
    
    private func addChampButtonView() {
        for index in playerRows.indices {
            if playerRows[index].activePlayer{
                championsSelected.append(playerRows[index])
            }
        }
        removeActivePlayers()
    }

    
    private func addDoublesRecord(endOfRound: Bool){
        if championsSelected.count != DOUBLES_PAIR_COUNT {
            return
        }

        doublesRecordList.append(DoublesRecord(
            player1Name: championsSelected[0].playerName,
            player2Name: championsSelected[1].playerName,
            timeSpentOnHill: stopwatchViewModel.elapsedPlayerTime,
            isRoundEndingTeam: endOfRound,
            round: roundCount
        ))
        
        doublesRecordList.sort {$0.timeSpentOnHill > $1.timeSpentOnHill}

    }
    
    private func resetAllActivePlayers() {
        for index in playerRows.indices {
            playerRows[index].activePlayer = false
        }
        playerSelectCount = championsSelected.count
    }
    
    private func resetDoublesRecord() {
        doublesRecordList = []
    }
    

    private func endRoundCleanUp() {
        stopwatchViewModel.stop()
        alertConfirmationChampions()
    }
    
    private func alertSelectChamps() {
        // Create an alert controller
        let alertController = UIAlertController(title: "Round Ended", message: "Select The two champions that ended the round", preferredStyle: .alert)

        // create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle response here.
        }
        // add the OK action to the alert controller
        alertController.addAction(OKAction)
    
        if let topViewController = UIApplication.shared.windows.first?.rootViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
     }

    private func alertConfirmationChampions() {

        if championsSelected.count < DOUBLES_PAIR_COUNT {
            return
        }
        let p1 = championsSelected[0].playerName
        let p2 = championsSelected[1].playerName
        // Create an alert controller
        let alertController = UIAlertController(title: "Select Champions", message: "Are you sure you want to choose \n\n \(p1)  +  \(p2) \n\n as champions?", preferredStyle: .alert)
       
       // Cancel Action is to reselect the actual champions.
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            addDoublesRecord(endOfRound: false)
            returnChampsBackToPlayerList()
            resetAllActivePlayers()
            stopwatchViewModel.resetPlayer()

        }
       alertController.addAction(cancelAction)
       
       // Add confirm action
       let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
           addDoublesRecord(endOfRound: true)
           roundScoresList.append(doublesRecordList)
           resetAllActivePlayers()
           roundEndScoreState = true
       }
       alertController.addAction(confirmAction)
       
        if let topViewController = UIApplication.shared.windows.first?.rootViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }

    
    private func nextRound() {
        stopwatchViewModel.stop()
//        submitSession(sessionName: selectedTennisClass, roundRecord: doublesRecordList, roundCount: roundCount)
        resetDoublesRecord()
        resetAllActivePlayers()
        stopwatchViewModel.resetRound()
        roundEndScoreState = false
        warningTimerExpiredAlarm = false
        roundTimerExpiredAlarm = false
        roundCount += 1
        stopwatchViewModel.start()

    }

    

}

#Preview {
    PlayerTimers(
        playerNames: .constant(["1", "2", "3",
                                "4", "5"]),
        timePerRound: .constant(ROUND_DEFAULT_PREVIEW_TIME),
        selectedTennisClass: .constant("FortuneTennis 4.0")
    )
}


