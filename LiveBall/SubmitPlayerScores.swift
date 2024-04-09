//
//  SubmitPlayerScores.swift
//  TennisApp
//
//  Created by Yee on 4/2/24.
//

import Foundation
import SwiftUI

struct ScoreSubmission: Codable {
    let id: UUID
    let timestamp: Date
    let selectedTennisClass: String
    let submitPlayerScores: [[DoublesRecord]]
}

struct SubmitPlayerScores: View {
    @Binding var roundScoresList: [[DoublesRecord]]
    @Binding var selectedTennisClass: String
    
    init(roundScoresList: Binding<[[DoublesRecord]]>, selectedTennisClass: Binding<String>) {
        _roundScoresList = roundScoresList
        _selectedTennisClass = selectedTennisClass
    }

        
    var body: some View {
        VStack {
            Text("\(selectedTennisClass)")
                .font(.title)
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
            Button(action: {
                submitSession()
            }) {
                Text("Submit Session")
            }
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
    
    private func submitSession() {
        let scores = ScoreSubmission(
            id: UUID(),
            timestamp: Date(),
            selectedTennisClass: "FortuneTennis 3.5",
            submitPlayerScores: roundScoresList.enumerated().map { (index, roundScores) in
                return roundScores.map { record in
                    var modifiedRecord = record // Make a mutable copy
                    modifiedRecord.round = index + 1 // Set the round attribute
                    return modifiedRecord
                }
            }

        )


        let encoder = JSONEncoder()

        // Set date encoding strategy to ISO8601
        encoder.dateEncodingStrategy = .iso8601

        do {
            // Encode the data to JSON format
            let jsonData = try encoder.encode(scores)
            
            // Convert JSON data to string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }


    }
    
    
}
struct SubmitPlayerScores_Previews: PreviewProvider {
    static var previews: some View {
        SubmitPlayerScores(roundScoresList: .constant(
            [
                [DoublesRecord(player1Name: "1 Player 1", player2Name: "1 Player 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "1 Player 3", player2Name: "1 Player 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "1 Player 5", player2Name: "1 Player 6", timeSpentOnHill: 150, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "1 Player 7", player2Name: "1 Player 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "2 Player 1", player2Name: "2 Player 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "2 Player 3", player2Name: "2 Player 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "2 Player 5", player2Name: "2 Player 6", timeSpentOnHill: 130, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "2 Player 7", player2Name: "2 Player 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "3 Player 1", player2Name: "3 Player 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "3 Player 3", player2Name: "3 Player 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "3 Player 5", player2Name: "3 Player 6", timeSpentOnHill: 120, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "3 Player 7", player2Name: "3 Player 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "4 Player 1", player2Name: "4 Player 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "4 Player 3", player2Name: "4 Player 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "4 Player 5", player2Name: "4 Player 6", timeSpentOnHill: 180, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "4 Player 7", player2Name: "4 Player 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "5 Player 1", player2Name: "5 Player 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "5 Player 3", player2Name: "5 Player 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "5 Player 5", player2Name: "5 Player 6", timeSpentOnHill: 150, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "5 Player 7", player2Name: "5 Player 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ]
            ]),
               selectedTennisClass: .constant("FortuneTennis 3.5")
        )

    }
}
