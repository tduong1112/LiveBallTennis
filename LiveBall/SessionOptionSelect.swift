//
//  TennisClassSelect.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

let DEFAULT_CREATE_CLASS_OPTION = "Loading"

class PathState: ObservableObject {
  enum Destination: String, Hashable {
    case playerClassSelected
  }
  @Published var path: [Destination] = []
}

class SessionRecordList: ObservableObject {
    @Published var roundRecords: [[DoublesRecord]] = []
    @Published var championPair: [PlayerItem] = []
    @Published var roundCount: Int = 1
    @Published var playerSelectCount: Int = 0

}


struct SessionOptionSelect: View {
    @StateObject var path_state = PathState()
    @StateObject var session_records = SessionRecordList()
    
    @State private var class_options = [DEFAULT_CREATE_CLASS_OPTION]
    @State private var selected_class = DEFAULT_CREATE_CLASS_OPTION

    @State private var show_alert = false // Alert state
    @State private var time_per_round = 15;
    @State private var selected_player_names: [String] = []
    @State private var player_name_input = ""
    
    @State private var select_regular_player = DEFAULT_CREATE_CLASS_OPTION
    @State private var regular_player_names = [DEFAULT_CREATE_CLASS_OPTION]
    @State private var session_clear_warning = false



    let time_per_roundPickerList = Array(1...30)
    
    
    var body: some View {
        NavigationStack (path: $path_state.path){
            VStack {
                Text("Create A Game")
                    .font(.title)
                HStack {
                    Text("Name of Class:")
                        .font(.title3)
                    Picker("Select an option", selection: $selected_class) {
                        ForEach(class_options, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle()) // Set the style of the Picker
                    .font(.title3)
                    .onChange(of: selected_class) {
                        getPlayerNamesFromClass(class_name: selected_class) { player_names_fetched, error in
                            if let player_names_fetched = player_names_fetched {
                                self.regular_player_names = player_names_fetched
                                
                            } else if let error = error {
                                print("Error: \(error.localizedDescription)")
                            } else {
                                print("Failed to fetch class names")
                            }
                        }
                    }
                    
                    // Code to execute when the selected option changes
                }
                .onAppear {
                    getClassNames { class_options_fetched, error in
                        if let class_options_fetched = class_options_fetched {
                            // Use the fetched class names here
                            self.class_options = class_options_fetched
                            self.selected_class = class_options[0]
                            
                        } else if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            print("Failed to fetch class names")
                        }
                    }
                }

                
                Text("Time per Round (minutes):")
                    .font(.title3)
                
                HStack {
                    
                    
                    Button(action: {
                        if time_per_round > 1 {
                            time_per_round -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle")
                    }
                    Text("\(time_per_round)")
                    Button(action: {
                        time_per_round += 1
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
                .padding()
                .font(.title)
                if regular_player_names.isEmpty{
                    Text("Fetching Player Names")
                } else {
                    HStack{
                        TextField("Player Name", text:$player_name_input)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .frame(width:300)
                        
                        Button(action: {
                            if !player_name_input.isEmpty {
                                selected_player_names.append(player_name_input)
                                player_name_input = ""
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size:30))
                        }
                        
                    }
                    HStack {
                        Text("Regular Player Selection: ")
                        Picker("Add Player", selection: $select_regular_player) {
                            ForEach(regular_player_names, id: \.self) { playerName in
                                Text(playerName)
                            }
                        }
                        .pickerStyle(MenuPickerStyle()) // Set the style of the Picker
                        .onChange(of: select_regular_player) {
                            if !select_regular_player.isEmpty {
                                selected_player_names.append(select_regular_player)
                                select_regular_player = ""
                            }
                        }
                    }

                }
                
                List {
                    ForEach(selected_player_names, id: \.self) { playerName in
                        HStack {
                            Button(action: {
                                if let index = selected_player_names.firstIndex(of: playerName) {
                                    selected_player_names.remove(at: index)
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
                    if selected_class != DEFAULT_CREATE_CLASS_OPTION {
                        NavigationLink(value: PathState.Destination.playerClassSelected) {
                            Text("Create Session")
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            session_records.roundRecords = []
                            print(session_records.roundRecords)
                        })
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(action: {
                            // Display error message here
                            self.show_alert = true
                        }) {
                            Text("Create Session")
                        }
                        .buttonStyle(.borderedProminent)
                        .alert(isPresented: $show_alert) {
                            Alert(title: Text("Error"), message: Text("Session Created Name is empty"), dismissButton: .default(Text("OK")))
                        }
                    }
                    if !session_records.roundRecords.isEmpty {
                        NavigationLink(value: PathState.Destination.playerClassSelected ) {
                            Text("Resume Session")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } // HStack
            } // VStack
              .navigationDestination(for: PathState.Destination.self) { destination in
                  switch destination {
                  case .playerClassSelected:
                      PlayerTimers(playerNames: $selected_player_names,
                                   timePerRound: $time_per_round,
                                   selectedTennisClass: $selected_class)
                      
                  }
              }

        } // NavigationStack
        .environmentObject(path_state)
        .environmentObject(session_records)

    } //Body View

}

#Preview {
    SessionOptionSelect()
}
