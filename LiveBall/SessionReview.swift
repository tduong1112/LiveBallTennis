//
//  SubmitPlayerScores.swift
//  TennisApp
//
//  Created by Yee on 4/2/24.
//

import Foundation
import SwiftUI

let ROUND_ENDING_POINTS = 1
let HIGHEST_TIME_ROUND_POINTS = 1
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
    @Binding var roundScoresList: [[DoublesRecord]]
    @Binding var selectedTennisClass: String
    
    @State var pointsViewToggle = false
    @State var playerScores = [String: Int]()
    
    
    init(roundScoresList: Binding<[[DoublesRecord]]>, selectedTennisClass: Binding<String>) {
        _roundScoresList = roundScoresList
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
            
            
            
            if pointsViewToggle {
                ForEach(roundScoresList.indices, id: \.self) { index in
                    Text("Round \(index + 1)")
                        .font(.title)
                    HStack {
                        if let winners = getRoundEndingTeams(forRound: roundScoresList[index]) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            
                            Text("\(winners.player1Name) and \(winners.player2Name)")
                        }
                    }
                    HStack{
                        if let roundMaxTime = getBestTime(forRound: roundScoresList[index]) {
                            Image(systemName: "stopwatch")
                            
                            Text("\(roundMaxTime.timeSpentOnHill / 60)m \(roundMaxTime.timeSpentOnHill % 60)s by \(roundMaxTime.player1Name) and \(roundMaxTime.player2Name)")
                        }
                    }
                    Spacer()
                    
                }
                if let sessionMaxTime = getBestTime(forSession: roundScoresList) {
                    HStack {
                        Image(systemName: "trophy")
                        Text("Session Best Time")
                            .font(.title)
                    }
                    Text("\(sessionMaxTime.timeSpentOnHill / 60)m \(sessionMaxTime.timeSpentOnHill % 60)s by \(sessionMaxTime.player1Name) and \(sessionMaxTime.player2Name)")
                    
                }
                NavigationLink(destination: SessionSubmit(roundScoresList: $roundScoresList,
                                                          selectedTennisClass: $selectedTennisClass)) {
                    Text("Submit Session")
                }
                                                          .buttonStyle(.borderedProminent)
                
            } else {
                let playerScores = self.getPlayerScoresFromRoundScoresList(forSession: roundScoresList)
                PlayerScoresView(playerScores: playerScores)
            }
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
    
    private func getPlayerScoresFromRoundScoresList(forSession session: [[DoublesRecord]]) -> [String: Int] {
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
    static var previews: some View {
        SessionReview(roundScoresList: .constant(
            [
                [DoublesRecord(player1Name: "1 TESTER 1", player2Name: "1 TESTER 2", timeSpentOnHill: 100, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "1 TESTER 3", player2Name: "1 TESTER 4", timeSpentOnHill: 3, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "1 TESTER 5", player2Name: "1 TESTER 6", timeSpentOnHill: 5, isRoundEndingTeam: true, round: 1),
                 DoublesRecord(player1Name: "1 TESTER 7", player2Name: "1 TESTER 8", timeSpentOnHill: 7, isRoundEndingTeam: false, round: 1)
                ],
                [DoublesRecord(player1Name: "5 TESTER 1", player2Name: "5 TESTER 2", timeSpentOnHill: 5, isRoundEndingTeam: false, round: 2),
                 DoublesRecord(player1Name: "5 TESTER 3", player2Name: "5 TESTER 4", timeSpentOnHill: 3, isRoundEndingTeam: false, round: 2),
                 DoublesRecord(player1Name: "5 TESTER 5", player2Name: "5 TESTER 6", timeSpentOnHill: 150, isRoundEndingTeam: true, round: 2),
                 DoublesRecord(player1Name: "5 TESTER 7", player2Name: "5 TESTER 8", timeSpentOnHill: 7, isRoundEndingTeam: false, round: 2)
                ]
            ]),
               selectedTennisClass: .constant("FortuneTennis 3.5")
        )

    }
}
