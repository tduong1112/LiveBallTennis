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
    let submitPlayerScores: [DoublesRecord]
    let round: Int
}

struct SessionReview: View {
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
            NavigationLink(destination: SessionSubmit(roundScoresList: $roundScoresList,
                                                           selectedTennisClass: $selectedTennisClass)) {
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
    
}
struct SessionReview_Previews: PreviewProvider {
    static var previews: some View {
        SessionReview(roundScoresList: .constant(
            [
                [DoublesRecord(player1Name: "1 TESTER 1", player2Name: "1 TESTER 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "1 TESTER 3", player2Name: "1 TESTER 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "1 TESTER 5", player2Name: "1 TESTER 6", timeSpentOnHill: 150, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "1 TESTER 7", player2Name: "1 TESTER 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "2 TESTER 1", player2Name: "2 TESTER 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "2 TESTER 3", player2Name: "2 TESTER 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "2 TESTER 5", player2Name: "2 TESTER 6", timeSpentOnHill: 130, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "2 TESTER 7", player2Name: "2 TESTER 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "3 TESTER 1", player2Name: "3 TESTER 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "3 TESTER 3", player2Name: "3 TESTER 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "3 TESTER 5", player2Name: "3 TESTER 6", timeSpentOnHill: 120, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "3 TESTER 7", player2Name: "3 TESTER 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "4 TESTER 1", player2Name: "4 TESTER 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "4 TESTER 3", player2Name: "4 TESTER 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "4 TESTER 5", player2Name: "4 TESTER 6", timeSpentOnHill: 180, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "4 TESTER 7", player2Name: "4 TESTER 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "5 TESTER 1", player2Name: "5 TESTER 2", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "5 TESTER 3", player2Name: "5 TESTER 4", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "5 TESTER 5", player2Name: "5 TESTER 6", timeSpentOnHill: 150, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "5 TESTER 7", player2Name: "5 TESTER 8", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ]
            ]),
               selectedTennisClass: .constant("FortuneTennis 3.5")
        )

    }
}
