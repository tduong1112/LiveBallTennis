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
    @State private var playerNames: [String] = ["asdf", "ber"]
    @State private var playerNameInput = ""
    
    @State private var selectRegularPlayer = ""
    @State private var regularPlayerNames = ["Manny", "Matthew", "Andre", "Vanessa", "Ben"]
    @State private var sessionClearWarning = false

    init(selectedTennisClass: Binding<String>)
    {
        _selectedTennisClass = selectedTennisClass
    }

    var body: some View {

        VStack {
            Text("Time per Round (minutes):")
            .font(.title3)

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
            .font(.title3)
        }
        VStack {
            HStack{
                TextField("Player Name", text:$playerNameInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(width:300)
                
                Button(action: {
                    if !playerNameInput.isEmpty {
                        playerNames.append(playerNameInput)
                        playerNameInput = ""
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size:30))
                }

            }
            HStack {
                Text("Regular Player Selection: ")
                Picker("Add Player", selection: $selectRegularPlayer) {
                    ForEach(regularPlayerNames, id: \.self) { playerName in
                        Text(playerName)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Set the style of the Picker
                .onChange(of: selectRegularPlayer) {
                    if !selectRegularPlayer.isEmpty {
                        playerNames.append(selectRegularPlayer)
                        selectRegularPlayer = ""
                    }
                }
            }

            List {
                ForEach(playerNames, id: \.self) { playerName in
                    HStack {
                        Button(action: {
                            if let index = playerNames.firstIndex(of: playerName) {
                                playerNames.remove(at: index)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        }

                        Text(playerName)
                        Spacer()
                    }
                }
            }
            .padding()

        }
        NavigationLink(destination: PlayerTimers(playerNames: $playerNames, timePerRound: $timePerRound, selectedTennisClass: $selectedTennisClass)) {
            Text("Create Session")
        }
        .buttonStyle(.borderedProminent)
        
    }
}

#Preview {
    SessionOptionSelect(
        selectedTennisClass: .constant("FortuneTennis 3.5")
    )
}
