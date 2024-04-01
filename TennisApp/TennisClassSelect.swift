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
    @State private var numPlayers = 1;
    let numberPlayersPickerList = Array(1...10) // Example range from 1 to 10

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
                Text("Create A Game")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                
                Text("Name of Class")
                Picker("Select an option", selection: $selectedClass) {
                    ForEach(classOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(DefaultPickerStyle()) // Set the style of the Picker
                .padding()
                
                Picker("Select how Many Players", selection: $numPlayers) {
                    ForEach(numberPlayersPickerList, id: \.self) { num in
                        Text("\(num)")
                    }
                }
                .pickerStyle(DefaultPickerStyle()) // Set the style of the Picker
                .padding()


                NavigationLink(destination:PlayerTimers(
                    selectedTennisClass: $selectedClass,
                    numPlayers: $numPlayers))
                {
                    Text("Select")
                        .padding()
                        .frame(width: 100, height:100);

                }
            }
        }
    }
}

#Preview {
    TennisClassSelect()
}
