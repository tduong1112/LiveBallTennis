//
//  SessionSubmit.swift
//  LiveBall
//
//  Created by Yee on 4/10/24.
//

import SwiftUI

struct SessionSubmit: View {
    @Binding var roundScoresList: [[DoublesRecord]]
    @Binding var selectedTennisClass: String
    @State private var submissionResult: String?

    
    init(roundScoresList: Binding<[[DoublesRecord]]>, selectedTennisClass: Binding<String>) {
        _roundScoresList = roundScoresList
        _selectedTennisClass = selectedTennisClass
    }
    
    var body: some View {

        
        VStack {
            Text("Submit Session Page")
                .onAppear {
                    // Run your function here
//                    submitSession()
                }
            
            if let result = submissionResult {
                Text("Submission Result: \(result)")
            }
            
            // Placeholder text when submissionResult is nil
            if submissionResult == nil {
                Text("Loading")
            }
            
//            Button(action: {
//                submitSession()
//            }) {
//                Text("Resubmit Session")
//            }
//            .buttonStyle(.borderedProminent)
        }
    }
    
    

}


func submitSession(sessionName: String, roundRecord: [DoublesRecord], roundCount: Int) -> String {
    let scores = ScoreSubmission(
        id: UUID(),
        timestamp: Date(),
        selectedTennisClass: sessionName,
        submitPlayerScores:  roundRecord,
        round: roundCount
    )
    
    var result = "Failed"


    let encoder = JSONEncoder()

    // Set date encoding strategy to ISO8601
    encoder.dateEncodingStrategy = .iso8601

    do {
        // Encode the data to JSON format
        let jsonData = try encoder.encode(scores)
        result = postSessionData(postData:  jsonData)
        // Convert JSON data to string
    } catch {
        print("Error encoding data: \(error.localizedDescription)")
    }
    return result
}

func postSessionData(postData : Data) -> String{
    var request = URLRequest(url: URL(string: "https://5rbu4c8mn8.execute-api.us-east-1.amazonaws.com/session")!,timeoutInterval: Double.infinity)
    var submissionResult = "Error"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "POST"
    request.httpBody = postData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Check for error
        if let error = error {
            print("Error: \(error)")
            return
        }

        // Check for response
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response")
            return
        }

        // Print status code
        print("Status Code: \(httpResponse.statusCode)")
        if httpResponse.statusCode == 200 {
            submissionResult = "Success"
        } else {
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                submissionResult = "Error: \(httpResponse.statusCode) - \(responseString)"
            } else {
                submissionResult = "Error: \(httpResponse.statusCode)"
            }
        }

        // Check for data
        guard let data = data else {
            print("No data received")
            return
        }

        // Print data as string
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Data: \(responseString)")
        } else {
            print("Unable to convert data to string")
        }
    }

    task.resume()
    return submissionResult
}

struct SubmitSession_Previews: PreviewProvider {
    static var previews: some View {
        SessionSubmit(roundScoresList: .constant(
            [
                [
                    DoublesRecord(player1Name: "1 TESTER 5", player2Name: "1 TESTER 6", timeSpentOnHill: 150, isRoundEndingTeam: true, round: 1),
                    DoublesRecord(player1Name: "1 TESTER 7", player2Name: "1 TESTER 8", timeSpentOnHill: 7, isRoundEndingTeam: false, round: 1)
                ],
                [
                 DoublesRecord(player1Name: "2 TESTER 5", player2Name: "2 TESTER 6", timeSpentOnHill: 130, isRoundEndingTeam: true, round: 2)
                 ]
            ]),
               selectedTennisClass: .constant("FortuneTennis 3.5")
        )

    }
}
