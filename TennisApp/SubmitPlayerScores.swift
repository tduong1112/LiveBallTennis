//
//  SubmitPlayerScores.swift
//  TennisApp
//
//  Created by Yee on 4/2/24.
//

import Foundation
import SwiftUI

struct SubmitPlayerScores: View {
    @State private var result: String = "Loading..." // Initial state for displaying loading message
        
        var body: some View {
            VStack {
                Text(result)
                    .padding()
                
                Button("Fetch Data") {
                    fetchData()
                }
                .padding()
            }
        }
        
        func fetchData() {
            guard let url = URL(string: "https://5rbu4c8mn8.execute-api.us-east-1.amazonaws.com") else {
                result = "Invalid URL"
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    result = "Error: \(error.localizedDescription)"
                } else if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        result = responseString
                    } else {
                        result = "Unable to decode response data"
                    }
                }
            }.resume()
        }
}

#Preview {
    SubmitPlayerScores()
}
