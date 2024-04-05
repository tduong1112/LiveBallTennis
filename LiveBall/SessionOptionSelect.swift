//
//  SessionOptionSelect.swift
//  LiveBall
//
//  Created by Yee on 4/5/24.
//

import SwiftUI

struct SessionOptionSelect: View {
    @Binding var selectedTennisClass: String
    
    @State private var timePerRound = 15;
    @State private var playerNames: [String] = []

    init(selectedTennisClass: Binding<String>)
    {
        _selectedTennisClass = selectedTennisClass
    }

    var body: some View {
        VStack {
            Text("Time per Round (minutes):")
            .font(.title)

            HStack {
                Button(action: {
                    if timePerRound > 1 {
                        timePerRound -= 1
                    }
                }) {
                    Image(systemName: "minus.circle")
                }
                Text("\(timePerRound)")
                Button(action: {
                    timePerRound += 1
                }) {
                    Image(systemName: "plus.circle")
                }
            }
            .padding()
            .font(.title)

        }
    }
}

#Preview {
    SessionOptionSelect(
        selectedTennisClass: .constant("FortuneTennis 3.5")
    )
}
