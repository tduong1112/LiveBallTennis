//
//  TennisClassSelect.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

struct TennisClassSelect: View {
    @State private var classOptions = ["Option A", "Option B", "Option C"]
    @State private var newItem = ""
    @State private var selectedClass = "Option 1"
    @State private var numPlayers = 4;
    @State private var timePerRound = 15;

    let numberPlayersPickerList = Array(4...10) // Example range from 1 to 10
    
    let timePerRoundPickerList: [Int] = {
        var array: [Int] = []
        for i in stride(from: 5, through: 30, by: 5) {
            array.append(i)
        }
        return array
    }()
    
    
    var body: some View {
        Text("Tennis Class View");
        NavigationView {
            VStack(alignment: .center) {
                TextField(
                    "Enter New Class",
                    text: $newItem
                )
                .padding()

                
                Button(action: {
                    self.classOptions.append(self.newItem)
                    self.newItem = ""
                }) {
                    Text("Add Class to List")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)

                }
                Spacer()
                VStack{
                    Text("Create A Game")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    HStack{
                        Text("Name of Class:")
                        Picker("Select an option", selection: $selectedClass) {
                            ForEach(classOptions, id: \.self) { option in
                                Text(option)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle()) // Set the style of the Picker
                    }
                    HStack{
                        Text("Number of Players:")
                        Picker("Num Players", selection: $numPlayers) {
                            ForEach(numberPlayersPickerList, id: \.self) { num in
                                Text("\(num)")
                            }
                        }
                        .pickerStyle(DefaultPickerStyle()) // Set the style of the Picker
                    }
                    
                    HStack{
                        Text("Time Per Round")
                        Picker("Time Per Round", selection: $timePerRound) {
                            ForEach(timePerRoundPickerList, id: \.self) { num in
                                Text("\(num)")
                            }
                        }
                        .pickerStyle(DefaultPickerStyle()) // Set the style of the Picker
                    }

                    NavigationLink(destination:PlayerTimers(
                        selectedTennisClass: $selectedClass,
                        numPlayers: $numPlayers,
                        timePerRound: $timePerRound))
                    {
                        Text("Select")
                            .padding()
                            .frame(width: 100, height:100);

                    }
                }
            }
        }
    }
}

#Preview {
    TennisClassSelect()
}
