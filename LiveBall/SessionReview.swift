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
    var playerScores: [String: (Int, Int, Int, Int, Int)]

    var body: some View {
        List(playerScores.sorted(by: { $0.value.3 > $1.value.3 }), id: \.key) { playerName, scores in
            HStack {
                Text(playerName)
                    .foregroundColor(.primary)
                    .font(.headline)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    VStack {
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
                Spacer()

                HStack {
                    let totalTimeSpentOnHill = scores.4
                    if (totalTimeSpentOnHill / 60) >= 1 {
                        Text("\(totalTimeSpentOnHill / 60)m")

                    }
                    Text("\(totalTimeSpentOnHill % 60)s")
                }
            
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
    @State var playerScores = [String: (Int, Int, Int, Int, Int)]()
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
                if let sessionMaxTime = getBestTime(forSession: sessionRecords.roundRecords) {
                    HStack {
                        Image(systemName: "trophy")
                            .foregroundColor(.yellow)

                        Text("Session Best Time")
                            .font(.title)
                    }
                    Text("\(sessionMaxTime.timeSpentOnHill / 60)m \(sessionMaxTime.timeSpentOnHill % 60)s by \(sessionMaxTime.player1Name) and \(sessionMaxTime.player2Name)")
                    
                }
                Spacer().frame(height: 30)

                
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
                    
                }

                
            } else {
                HStack{
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("= 1 Point ")
                    Image(systemName: "timer")
                    Text("= 3 Point ")
                    Image(systemName: "trophy")
                        .foregroundColor(.yellow)
                    Text("= 5 Point ")
                }
                let playerScores = self.getPlayerScoresFromSession(session: sessionRecords.roundRecords)
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
    
    private func getPlayerScoresFromSession(session: [[DoublesRecord]]) -> [String: (Int, Int, Int, Int, Int)] {
        // (ROUND_ENDING_POINTS_INDEX, HIGHEST_TIME_ROUND_POINTS_INDEX, HIGHEST_TIME_SESSION_BOOL_INDEX, TOTAL_SCORE_INDEX, TOTAL_TIME_INDEX)
        var tempPlayerScores: [String: (Int, Int, Int, Int, Int)] = [:]

        // Intialize
        for round in sessionRecords.roundRecords {
            for record in round {
                if let score = tempPlayerScores[record.player1Name] {
                    tempPlayerScores[record.player1Name] = (score.0, score.1, score.2, score.3, score.4 + record.timeSpentOnHill)
                } else {
                    tempPlayerScores[record.player1Name] = (0, 0, 0, 0, record.timeSpentOnHill)
                }
                
                if let score = tempPlayerScores[record.player2Name] {
                    tempPlayerScores[record.player2Name] = (score.0, score.1, score.2, score.3, score.4 + record.timeSpentOnHill)

                } else {
                    tempPlayerScores[record.player2Name] = (0, 0, 0, 0, record.timeSpentOnHill)
                }
            }

            if let roundWinningRecord = round.first(where: { $0.isRoundEndingTeam }) {
                if let score = tempPlayerScores[roundWinningRecord.player1Name] {

                    tempPlayerScores[roundWinningRecord.player1Name] = (score.0 + 1, score.1, score.2, score.3 + ROUND_ENDING_POINTS, score.4)


                }
                if let score = tempPlayerScores[roundWinningRecord.player2Name] {
                    tempPlayerScores[roundWinningRecord.player2Name] = (score.0 + 1, score.1, score.2, score.3 + ROUND_ENDING_POINTS, score.4)
                }
            }
            if let roundLongestRecord = round.max(by: { $0.timeSpentOnHill < $1.timeSpentOnHill }) {
                if let score = tempPlayerScores[roundLongestRecord.player1Name] {
                    tempPlayerScores[roundLongestRecord.player1Name] = (score.0, score.1 + 1, score.2, score.3 + HIGHEST_TIME_ROUND_POINTS, score.4)


                }
                if let score = tempPlayerScores[roundLongestRecord.player2Name] {
                    tempPlayerScores[roundLongestRecord.player2Name] = (score.0 , score.1 + 1, score.2, score.3 + HIGHEST_TIME_ROUND_POINTS, score.4)

                }
            }
                
        }
        if let sessionLongestRecord = session.flatMap({ $0 }).max(by: { $0.timeSpentOnHill < $1.timeSpentOnHill }) {
            if let score = tempPlayerScores[sessionLongestRecord.player1Name] {
                tempPlayerScores[sessionLongestRecord.player1Name] = (score.0,
                                                                      score.1 - 1, // Subract one from Highest round which is repeated in session highest
                                                                      score.2 + 1,
                                                                      score.3 + HIGHEST_TIME_SESSION_POINTS - HIGHEST_TIME_ROUND_POINTS, 
                                                                      score.4)

            }
            if let score = tempPlayerScores[sessionLongestRecord.player2Name] {
                tempPlayerScores[sessionLongestRecord.player2Name] = (score.0,
                                                                      score.1 - 1, // Subract one from Highest round which is repeated in session highest
                                                                      score.2 + 1,
                                                                      score.3 + HIGHEST_TIME_SESSION_POINTS - HIGHEST_TIME_ROUND_POINTS,
                                                                      score.4)
            }
        }
        return tempPlayerScores
    }
    

}
struct SessionReview_Previews: PreviewProvider {
    static var previews: some View {
        let sessionRecords = SessionRecordList()
            sessionRecords.roundRecords = [
                [DoublesRecord(player1Name: "A", player2Name: "B", timeSpentOnHill: 201, isRoundEndingTeam: true, round: 1),
                 DoublesRecord(player1Name: "B", player2Name: "D", timeSpentOnHill: 135, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "E", player2Name: "F", timeSpentOnHill: 24, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "G", player2Name: "H", timeSpentOnHill: 152, isRoundEndingTeam: false, round: 1)
                ],
                [DoublesRecord(player1Name: "A", player2Name: "B", timeSpentOnHill: 3, isRoundEndingTeam: true, round: 1),
                 DoublesRecord(player1Name: "B", player2Name: "D", timeSpentOnHill: 152, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "E", player2Name: "F", timeSpentOnHill: 43, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "G", player2Name: "H", timeSpentOnHill: 144, isRoundEndingTeam: false, round: 1)
                ],
                [DoublesRecord(player1Name: "A", player2Name: "B", timeSpentOnHill: 5, isRoundEndingTeam: true, round: 1),
                 DoublesRecord(player1Name: "B", player2Name: "D", timeSpentOnHill: 133, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "E", player2Name: "F", timeSpentOnHill: 24, isRoundEndingTeam: false, round: 1),
                 DoublesRecord(player1Name: "G", player2Name: "H", timeSpentOnHill: 200, isRoundEndingTeam: false, round: 1)
                ],
            ];

            return SessionReview(selectedTennisClass: .constant("FortuneTennis 3.5"))
                .environmentObject(PathState())
                .environmentObject(sessionRecords)
        }
}
