//
//  TennisClassSelect.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

let DEFAULT_CREATE_CLASS_OPTION = "Create a class"

class PathState: ObservableObject {
  enum Destination: String, Hashable {
    case playerClassWritten, playerClassSelected
  }
  @Published var path: [Destination] = []
}

class SessionRecordList: ObservableObject {
    @Published var roundRecords: [[DoublesRecord]] = []
}

struct SessionOptionSelect: View {
    @StateObject var pathState = PathState()
    @StateObject var sessionRecords = SessionRecordList()

    @State private var classOptions = [DEFAULT_CREATE_CLASS_OPTION,
                                       "FortuneTennis 3.5",
                                       "FortuneTennis 3.5-4.0+",
                                       "FortuneTennis 4.0",
                                       "FortuneTennis 4.5",
                                       "FortuneTennis 5.0",
                                       "Test Ben"
                                       ]
    @State private var newClassName = ""
    @State private var selectedClass = DEFAULT_CREATE_CLASS_OPTION

    @State private var showAlert = false // Alert state
    @State private var timePerRound = 15;
    @State private var playerNames: [String] = ["Manny"]
    @State private var playerNameInput = ""
    
    @State private var selectRegularPlayer = ""
    @State private var regularPlayerNames = ["Manny", "Matthew", "Andre", "Vanessa", "Ben"]
    @State private var sessionClearWarning = false



    let timePerRoundPickerList = Array(1...30)
    
    
    var body: some View {
        NavigationStack (path: $pathState.path){
            VStack {
                Text("Create A Game")
                    .font(.title)
                HStack {
                    Text("Name of Class:")
                        .font(.title3)
                    Picker("Select an option", selection: $selectedClass) {
                        ForEach(classOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle()) // Set the style of the Picker
                    .font(.title3)
                    
                }
                if selectedClass == DEFAULT_CREATE_CLASS_OPTION {
                    TextField(
                        "Enter Class Name",
                        text: $newClassName
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width:300)
                    .font(.title3)
                }
                Spacer().frame(height: 50)
                
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
                .font(.title)
            
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
                HStack{
                    if selectedClass != DEFAULT_CREATE_CLASS_OPTION {
                        NavigationLink(value: PathState.Destination.playerClassSelected) {
                            Text("Create Session")
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            sessionRecords.roundRecords = []
                            print(sessionRecords.roundRecords)
                        })
                        .buttonStyle(.borderedProminent)
                    } else if selectedClass == DEFAULT_CREATE_CLASS_OPTION && !newClassName.isEmpty {
                        NavigationLink(value: PathState.Destination.playerClassWritten ) {
                            Text("Create Session Written")
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            sessionRecords.roundRecords = []
                            print(sessionRecords.roundRecords)
                        })
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(action: {
                            // Display error message here
                            self.showAlert = true
                        }) {
                            Text("Create Session")
                        }
                        .buttonStyle(.borderedProminent)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text("Session Created Name is empty"), dismissButton: .default(Text("OK")))
                        }
                    }
                    if !sessionRecords.roundRecords.isEmpty {
                        NavigationLink(value: PathState.Destination.playerClassSelected ) {
                            Text("Resume Session")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } // HStack
            } // VStack
              .navigationDestination(for: PathState.Destination.self) { destination in
                  switch destination {
                  case .playerClassWritten:
                      PlayerTimers(playerNames: $playerNames,
                                   timePerRound: $timePerRound,
                                   selectedTennisClass: $newClassName)
                  case .playerClassSelected:
                      PlayerTimers(playerNames: $playerNames, 
                                   timePerRound: $timePerRound,
                                   selectedTennisClass: $selectedClass)
                      
                  }
              }

        } // NavigationStack
        .environmentObject(pathState)
        .environmentObject(sessionRecords)

    } //Body View

}

#Preview {
    SessionOptionSelect()
}
