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
    var playerScores: [String: (Int, Int, Int, Int)]

    var body: some View {
        List(playerScores.sorted(by: { $0.value.3 > $1.value.3 }), id: \.key) { playerName, scores in
            HStack {
                Text(playerName)
                    .foregroundColor(.primary)
                    .font(.headline)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack {
                        Text("\(scores.0) x")
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("= \(scores.0 * ROUND_ENDING_POINTS)")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    HStack {
                        Text("\(scores.1) x")
                        Image(systemName: "stopwatch")
                        Text("= \(scores.1 * HIGHEST_TIME_ROUND_POINTS)")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    if scores.2 > 0 {
                        HStack {
                            Text("\(scores.2) x")
                            Image(systemName: "trophy")
                                .foregroundColor(.yellow)
                            Text("= \(scores.2 * HIGHEST_TIME_SESSION_POINTS)")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    }
                }
            
                Text("Total: \(scores.3)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
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
            
            
            
            if pointsViewToggle {
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
                            .foregroundColor(.yellow)

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
    
    private func getPlayerScoresFromSession(forSession session: [[DoublesRecord]]) -> [String: (Int, Int, Int, Int)]{
        // (ROUND_ENDING_POINTS_INDEX, HIGHEST_TIME_ROUND_POINTS_INDEX, HIGHEST_TIME_SESSION_BOOL_INDEX, TOTAL_SCORE_INDEX)

        var tempPlayerScores: [String: (Int, Int, Int, Int)] = [:]
        // Intialize
        for round in session {
            for record in round {
                if let playerScore = tempPlayerScores[record.player1Name] {
                    // Do nothing
                } else {
                    tempPlayerScores[record.player1Name] = (0, 0, 0, 0)
                    tempPlayerScores[record.player2Name] = (0, 0, 0, 0)
                }

                
            }
            if let roundWinningRecord = round.first(where: { $0.isRoundEndingTeam }) {
                if var score = tempPlayerScores[roundWinningRecord.player1Name] {

                    tempPlayerScores[roundWinningRecord.player1Name] = (score.0 + 1, score.1, score.2, score.3 + ROUND_ENDING_POINTS)


                }
                if var score = tempPlayerScores[roundWinningRecord.player2Name] {
                    tempPlayerScores[roundWinningRecord.player2Name] = (score.0 + 1, score.1, score.2, score.3 + ROUND_ENDING_POINTS)
                }
            }
            if let roundLongestRecord = round.max(by: { $0.timeSpentOnHill < $1.timeSpentOnHill }) {
                if var score = tempPlayerScores[roundLongestRecord.player1Name] {
                    tempPlayerScores[roundLongestRecord.player1Name] = (score.0, score.1 + 1, score.2, score.3 + HIGHEST_TIME_ROUND_POINTS)


                }
                if var score = tempPlayerScores[roundLongestRecord.player2Name] {
                    tempPlayerScores[roundLongestRecord.player2Name] = (score.0 , score.1 + 1, score.2, score.3 + HIGHEST_TIME_ROUND_POINTS)

                }
            }
                
        }
        if let sessionLongestRecord = session.flatMap({ $0 }).max(by: { $0.timeSpentOnHill < $1.timeSpentOnHill }) {
            if var score = tempPlayerScores[sessionLongestRecord.player1Name] {
                tempPlayerScores[sessionLongestRecord.player1Name] = (score.0 , score.1, score.2 + 1, score.3 + HIGHEST_TIME_SESSION_POINTS)

            }
            if var score = tempPlayerScores[sessionLongestRecord.player2Name] {
                tempPlayerScores[sessionLongestRecord.player1Name] = (score.0 , score.1, score.2 + 1, score.3 + HIGHEST_TIME_SESSION_POINTS)
            }
        }
        return tempPlayerScores
    }

}
struct SessionReview_Previews: PreviewProvider {
    static var previews: some View {
            let sessionRecords = SessionRecordList()
            sessionRecords.roundRecords = [
                [DoublesRecord(player1Name: "1 TESTER 1", player2Name: "1 TESTER 2", timeSpentOnHill: 1, isRoundEndingTeam: true, round: 1),
                 DoublesRecord(player1Name: "1 TESTER 3", player2Name: "1 TESTER 4", timeSpentOnHill: 2, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "1 TESTER 5", player2Name: "1 TESTER 6", timeSpentOnHill: 3, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "1 TESTER 7", player2Name: "1 TESTER 8", timeSpentOnHill: 4, isRoundEndingTeam: false, round: 1)
                ],
                [DoublesRecord(player1Name: "1 TESTER 1", player2Name: "1 TESTER 2", timeSpentOnHill: 1, isRoundEndingTeam: false, round: 2),
                 DoublesRecord(player1Name: "1 TESTER 3", player2Name: "1 TESTER 4", timeSpentOnHill: 2, isRoundEndingTeam: false, round: 2),
                 DoublesRecord(player1Name: "1 TESTER 5", player2Name: "1 TESTER 6", timeSpentOnHill: 3, isRoundEndingTeam: false, round: 2),
                 DoublesRecord(player1Name: "1 TESTER 7", player2Name: "1 TESTER 8", timeSpentOnHill: 4, isRoundEndingTeam: true, round: 2)
                ],
                [DoublesRecord(player1Name: "1 TESTER 1", player2Name: "1 TESTER 2", timeSpentOnHill: 1, isRoundEndingTeam: false, round: 3),
                 DoublesRecord(player1Name: "1 TESTER 3", player2Name: "1 TESTER 4", timeSpentOnHill: 2, isRoundEndingTeam: false, round: 3),
                 DoublesRecord(player1Name: "1 TESTER 5", player2Name: "1 TESTER 6", timeSpentOnHill: 3, isRoundEndingTeam: false, round: 3),
                 DoublesRecord(player1Name: "1 TESTER 7", player2Name: "1 TESTER 8", timeSpentOnHill: 4, isRoundEndingTeam: true, round: 3)
                ],
                [DoublesRecord(player1Name: "1 TESTER 1", player2Name: "1 TESTER 2", timeSpentOnHill: 1, isRoundEndingTeam: false, round: 4),
                 DoublesRecord(player1Name: "1 TESTER 3", player2Name: "1 TESTER 4", timeSpentOnHill: 2, isRoundEndingTeam: false, round: 4),
                 DoublesRecord(player1Name: "1 TESTER 5", player2Name: "1 TESTER 6", timeSpentOnHill: 3, isRoundEndingTeam: false, round: 4),
                 DoublesRecord(player1Name: "1 TESTER 7", player2Name: "1 TESTER 8", timeSpentOnHill: 4, isRoundEndingTeam: true, round: 4)
                ],
                [DoublesRecord(player1Name: "1 TESTER 1", player2Name: "1 TESTER 2", timeSpentOnHill: 1, isRoundEndingTeam: false, round: 5),
                 DoublesRecord(player1Name: "1 TESTER 3", player2Name: "1 TESTER 4", timeSpentOnHill: 2, isRoundEndingTeam: false, round: 5),
                 DoublesRecord(player1Name: "1 TESTER 5", player2Name: "1 TESTER 6", timeSpentOnHill: 3, isRoundEndingTeam: false, round: 5),
                 DoublesRecord(player1Name: "1 TESTER 7", player2Name: "1 TESTER 8", timeSpentOnHill: 4, isRoundEndingTeam: true, round: 5)
                ],
            ];

            return SessionReview(selectedTennisClass: .constant("FortuneTennis 3.5"))
                .environmentObject(PathState())
                .environmentObject(sessionRecords)
        }
}
