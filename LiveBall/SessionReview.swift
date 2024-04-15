//
//  SubmitPlayerScores.swift
//  TennisApp
//
//  Created by Yee on 4/2/24.
//

import Foundation
import SwiftUI

let ROUND_ENDING_POINTS = 1
let HIGHEST_TIME_ROUND_POINTS = 3
let HIGHEST_TIME_SESSION_POINTS = 5

struct PlayerScoresView: View {
    var playerScores: [String: Int]

    var body: some View {
        let filteredScores = playerScores.filter { $0.value != 0 }
                                        .sorted(by: { $0.value > $1.value })

        return List {
            ForEach(filteredScores, id: \.key) { playerScore in
                HStack {
                    Text(playerScore.key)
                    Spacer()
                    Text("\(playerScore.value)")
                }
            }
        }
        .navigationTitle("Player Scores")
    }
}

struct ScoreSubmission: Codable {
    let id: UUID
    let timestamp: Date
    let selectedTennisClass: String
    let submitPlayerScores: [DoublesRecord]
    let round: Int
}

struct SessionReview: View {
    @EnvironmentObject var pathState: PathState
    @EnvironmentObject var sessionRecords : SessionRecordList
    @Binding var selectedTennisClass: String
    
    @State var pointsViewToggle = false
    @State var playerScores = [String: Int]()
    @State private var navigateBack = false

    
    init(selectedTennisClass: Binding<String>) {
        _selectedTennisClass = selectedTennisClass
    }

        
    var body: some View {
        VStack {
            Text("\(selectedTennisClass)")
                .font(.title)
            Button(action: {
                pointsViewToggle.toggle()
            }) {
                Text(pointsViewToggle ? "Points View" : "Summary View")
            }
            .buttonStyle(.borderedProminent)
            Spacer().frame(height:20)
            
            
            
            if !pointsViewToggle {
                ForEach(sessionRecords.roundRecords.indices, id: \.self) { index in
                    Text("Round \(index + 1)")
                        .font(.title)
                    HStack{
                        if let roundMaxTime = getBestTime(forRound: sessionRecords.roundRecords[index]) {
                            Image(systemName: "stopwatch")
                            
                            Text("\(roundMaxTime.timeSpentOnHill / 60)m \(roundMaxTime.timeSpentOnHill % 60)s by \(roundMaxTime.player1Name) and \(roundMaxTime.player2Name)")
                        }
                    }
                    HStack {
                        if let winners = getRoundEndingTeams(forRound: sessionRecords.roundRecords[index]) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            
                            Text("\(winners.player1Name) and \(winners.player2Name)")
                        }
                    }
                    Spacer()
                    
                }
                if let sessionMaxTime = getBestTime(forSession: sessionRecords.roundRecords) {
                    HStack {
                        Image(systemName: "trophy")
                        Text("Session Best Time")
                            .font(.title)
                    }
                    Text("\(sessionMaxTime.timeSpentOnHill / 60)m \(sessionMaxTime.timeSpentOnHill % 60)s by \(sessionMaxTime.player1Name) and \(sessionMaxTime.player2Name)")
                    
                }
                
            } else {
                let playerScores = self.getPlayerScoresFromSession(forSession: sessionRecords.roundRecords)
                PlayerScoresView(playerScores: playerScores)
            }

            Button(action: {
                pathState.path = .init() // take everything off the navigation stack
                sessionRecords.roundRecords = .init()
            }, label: {
              Text("Create New Session")
            })
           .buttonStyle(.borderedProminent)

        }


    }
    
    private func getRoundEndingTeams(forRound round: [DoublesRecord]) -> DoublesRecord? {
        return round.first(where: { $0.isRoundEndingTeam })
    }
    
    private func getBestTime(forRound round: [DoublesRecord]) -> DoublesRecord? {
        return round.max(by: { $0.timeSpentOnHill < $1.timeSpentOnHill })
    }
    
    private func getBestTime(forSession session: [[DoublesRecord]]) -> DoublesRecord? {
        return session.flatMap { $0 }.max(by: { $0.timeSpentOnHill < $1.timeSpentOnHill })
    }
    
    private func getPlayerScoresFromSession(forSession session: [[DoublesRecord]]) -> [String: Int] {
        var tempPlayerScores = [String: Int]()
        // Intialize
        for round in session {
            for record in round {
                tempPlayerScores[record.player1Name] = 0
                tempPlayerScores[record.player2Name] = 0
            }
            if let roundWinningRecord = round.first(where: { $0.isRoundEndingTeam }) {
                if let score = tempPlayerScores[roundWinningRecord.player1Name] {
                    tempPlayerScores.updateValue(score + ROUND_ENDING_POINTS, forKey: roundWinningRecord.player1Name)
                }
                if let score = tempPlayerScores[roundWinningRecord.player2Name] {
                    tempPlayerScores.updateValue(score + ROUND_ENDING_POINTS, forKey: roundWinningRecord.player2Name)
                }
            }
            if let roundLongestRecord = round.max(by: { $0.timeSpentOnHill < $1.timeSpentOnHill }) {
                if let score = tempPlayerScores[roundLongestRecord.player1Name] {
                    tempPlayerScores.updateValue(score + HIGHEST_TIME_ROUND_POINTS, forKey: roundLongestRecord.player1Name)
                }
                if let score = tempPlayerScores[roundLongestRecord.player2Name] {
                    tempPlayerScores.updateValue(score + HIGHEST_TIME_ROUND_POINTS, forKey: roundLongestRecord.player2Name)
                }
            }
        }
        
        if let sessionLongestRecord = session.flatMap({ $0 }).max(by: { $0.timeSpentOnHill < $1.timeSpentOnHill }) {
            if let score = tempPlayerScores[sessionLongestRecord.player1Name] {
                tempPlayerScores.updateValue(score + HIGHEST_TIME_SESSION_POINTS, forKey: sessionLongestRecord.player1Name)
            }
            if let score = tempPlayerScores[sessionLongestRecord.player2Name] {
                tempPlayerScores.updateValue(score + HIGHEST_TIME_SESSION_POINTS, forKey: sessionLongestRecord.player2Name)
            }
        }

        // Debug Prints
        /*
        for player in tempPlayerScores {
            print(player)
        }
        print("\n_________\n")
         */
        return tempPlayerScores
    }
    
}
struct SessionReview_Previews: PreviewProvider {
    static let sessionRecords = SessionRecordList()
    static var previews: some View {
        SessionReview(selectedTennisClass: .constant("FortuneTennis 3.5")
        )
        .environmentObject(PathState())
        .environmentObject(sessionRecords)
    }
}
