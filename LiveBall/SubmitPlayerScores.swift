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
            let jsonString = String(data: jsonData, encoding: .utf8)
            postSessionData(jsonData:  jsonData)
            // Convert JSON data to string
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
    
    private func postSessionData(jsonData : Data) {
        let parameters = "{\n  \"selectedTennisClass\": \"FortuneTennis 3.5\",\n  \"id\": \"DCB790A9-1AC2-44DC-AF57-8E095690E4AC\",\n  \"timestamp\": \"2024-04-09T20:05:47Z\",\n  \"submitPlayerScores\": [\n    [\n      {\n        \"player1Name\": \"1 Player 1\",\n        \"timeSpentOnHill\": 5,\n        \"isRoundEndingTeam\": false,\n        \"player2Name\": \"1 Player 2\",\n        \"round\": 1\n      },\n      {\n        \"isRoundEndingTeam\": false,\n        \"timeSpentOnHill\": 3,\n        \"player1Name\": \"1 Player 3\",\n        \"player2Name\": \"1 Player 4\",\n        \"round\": 1\n      },\n      {\n        \"timeSpentOnHill\": 150,\n        \"isRoundEndingTeam\": true,\n        \"player2Name\": \"1 Player 6\",\n        \"round\": 1,\n        \"player1Name\": \"1 Player 5\"\n      },\n      {\n        \"player2Name\": \"1 Player 8\",\n        \"player1Name\": \"1 Player 7\",\n        \"isRoundEndingTeam\": false,\n        \"round\": 1,\n        \"timeSpentOnHill\": 7\n      }\n    ],\n    [\n      {\n        \"player1Name\": \"2 Player 1\",\n        \"player2Name\": \"2 Player 2\",\n        \"timeSpentOnHill\": 5,\n        \"isRoundEndingTeam\": false,\n        \"round\": 2\n      },\n      {\n        \"isRoundEndingTeam\": false,\n        \"player1Name\": \"2 Player 3\",\n        \"player2Name\": \"2 Player 4\",\n        \"timeSpentOnHill\": 3,\n        \"round\": 2\n      },\n      {\n        \"isRoundEndingTeam\": true,\n        \"round\": 2,\n        \"player2Name\": \"2 Player 6\",\n        \"player1Name\": \"2 Player 5\",\n        \"timeSpentOnHill\": 130\n      },\n      {\n        \"player1Name\": \"2 Player 7\",\n        \"player2Name\": \"2 Player 8\",\n        \"timeSpentOnHill\": 7,\n        \"isRoundEndingTeam\": false,\n        \"round\": 2\n      }\n    ],\n    [\n      {\n        \"isRoundEndingTeam\": false,\n        \"player1Name\": \"3 Player 1\",\n        \"timeSpentOnHill\": 5,\n        \"round\": 3,\n        \"player2Name\": \"3 Player 2\"\n      },\n      {\n        \"round\": 3,\n        \"player2Name\": \"3 Player 4\",\n        \"timeSpentOnHill\": 3,\n        \"player1Name\": \"3 Player 3\",\n        \"isRoundEndingTeam\": false\n      },\n      {\n        \"isRoundEndingTeam\": true,\n        \"timeSpentOnHill\": 120,\n        \"player1Name\": \"3 Player 5\",\n        \"round\": 3,\n        \"player2Name\": \"3 Player 6\"\n      },\n      {\n        \"isRoundEndingTeam\": false,\n        \"round\": 3,\n        \"player2Name\": \"3 Player 8\",\n        \"player1Name\": \"3 Player 7\",\n        \"timeSpentOnHill\": 7\n      }\n    ],\n    [\n      {\n        \"isRoundEndingTeam\": false,\n        \"timeSpentOnHill\": 5,\n        \"round\": 4,\n        \"player2Name\": \"4 Player 2\",\n        \"player1Name\": \"4 Player 1\"\n      },\n      {\n        \"timeSpentOnHill\": 3,\n        \"player1Name\": \"4 Player 3\",\n        \"player2Name\": \"4 Player 4\",\n        \"round\": 4,\n        \"isRoundEndingTeam\": false\n      },\n      {\n        \"player1Name\": \"4 Player 5\",\n        \"round\": 4,\n        \"player2Name\": \"4 Player 6\",\n        \"timeSpentOnHill\": 180,\n        \"isRoundEndingTeam\": true\n      },\n      {\n        \"timeSpentOnHill\": 7,\n        \"player1Name\": \"4 Player 7\",\n        \"player2Name\": \"4 Player 8\",\n        \"round\": 4,\n        \"isRoundEndingTeam\": false\n      }\n    ],\n    [\n      {\n        \"player2Name\": \"5 Player 2\",\n        \"timeSpentOnHill\": 5,\n        \"isRoundEndingTeam\": false,\n        \"player1Name\": \"5 Player 1\",\n        \"round\": 5\n      },\n      {\n        \"isRoundEndingTeam\": false,\n        \"round\": 5,\n        \"player1Name\": \"5 Player 3\",\n        \"player2Name\": \"5 Player 4\",\n        \"timeSpentOnHill\": 3\n      },\n      {\n        \"player1Name\": \"5 Player 5\",\n        \"isRoundEndingTeam\": true,\n        \"player2Name\": \"5 Player 6\",\n        \"timeSpentOnHill\": 150,\n        \"round\": 5\n      },\n      {\n        \"player2Name\": \"5 Player 8\",\n        \"isRoundEndingTeam\": false,\n        \"round\": 5,\n        \"timeSpentOnHill\": 7,\n        \"player1Name\": \"5 Player 7\"\n      }\n    ]\n  ]\n}\n"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://5rbu4c8mn8.execute-api.us-east-1.amazonaws.com/session")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
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
