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
            Text("\(roundScoresList[0])")
        }
    }
}
struct SubmitPlayerScores_Previews: PreviewProvider {
    static var previews: some View {
        SubmitPlayerScores(roundScoresList: .constant(
            [
                [DoublesRecord(player1Name: "Alex", player2Name: "Karen", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Chris", player2Name: "Ben", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Jeff", player2Name: "Timothy", timeSpentOnHill: 6, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "Melody", player2Name: "Ben", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "Alex", player2Name: "Karen", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Chris", player2Name: "Ben", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Jeff", player2Name: "Timothy", timeSpentOnHill: 6, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "Melody", player2Name: "Ben", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ],
                [DoublesRecord(player1Name: "Alex", player2Name: "Karen", timeSpentOnHill: 5, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Chris", player2Name: "Ben", timeSpentOnHill: 3, isRoundEndingTeam: false),
                 DoublesRecord(player1Name: "Jeff", player2Name: "Timothy", timeSpentOnHill: 6, isRoundEndingTeam: true),
                 DoublesRecord(player1Name: "Melody", player2Name: "Ben", timeSpentOnHill: 7, isRoundEndingTeam: false)
                ]
            ])
        )
    }
}
