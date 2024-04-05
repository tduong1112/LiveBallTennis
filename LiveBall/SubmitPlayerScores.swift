//
//  SubmitPlayerScores.swift
//  TennisApp
//
//  Created by Yee on 4/2/24.
//

import Foundation
import SwiftUI

struct SubmitPlayerScores: View {
    @Binding var roundScoresList: [[DoublesRecord]]
    
    init(roundScoresList: Binding<[[DoublesRecord]]>) {
        _roundScoresList = roundScoresList
    }

        
    var body: some View {
        VStack {
            ForEach(roundScoresList.indices, id: \.self) { index in
                Text("Round \(index + 1)")
                    .font(.title)
                if let winners = getRoundEndingTeams(forRound: roundScoresList[index]) {
                    Text("Round End Winners: \(winners.player1Name) and \(winners.player2Name)")
                }
                
                if let roundMaxTime = getBestTime(forRound: roundScoresList[index]) {
                    Text("Best Time: \(roundMaxTime.timeSpentOnHill / 60)m \(roundMaxTime.timeSpentOnHill % 60)s by \(roundMaxTime.player1Name) and \(roundMaxTime.player2Name)")
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
    
    
}
struct SubmitPlayerScores_Previews: PreviewProvider {
    static var previews: some View {
        SubmitPlayerScores(roundScoresList: .constant(
            [
                [DoublesRecord(player1Name: "Alex", player2Name: "Karen", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Chris", player2Name: "Ben", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Jeff", player2Name: "Timothy", timeSpentOnHill: 150, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "Melody", player2Name: "Ben", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "Alex", player2Name: "Karen", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Chris", player2Name: "Ben", timeSpentOnHill: 3, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "Jeff", player2Name: "Timothy", timeSpentOnHill: 6, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Melody", player2Name: "Ben", timeSpentOnHill: 200, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "Alex", player2Name: "Karen", timeSpentOnHill: 100, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "Chris", player2Name: "Ben", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Jeff", player2Name: "Timothy", timeSpentOnHill: 6, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Melody", player2Name: "Ben", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "Alex", player2Name: "Karen", timeSpentOnHill: 100, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "Chris", player2Name: "Ben", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Jeff", player2Name: "Timothy", timeSpentOnHill: 6, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Melody", player2Name: "Ben", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "Alex", player2Name: "Karen", timeSpentOnHill: 100, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "Chris", player2Name: "Ben", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Jeff", player2Name: "Timothy", timeSpentOnHill: 6, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Melody", player2Name: "Ben", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ]
            ])
        )
    }
}
