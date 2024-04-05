//
//  TennisClassSelect.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

let DEFAULT_CREATE_CLASS_OPTION = "Create a class"

struct TennisClassSelect: View {
    @State private var classOptions = [DEFAULT_CREATE_CLASS_OPTION,
                                       "FortuneTennis 3.5",
                                       "FortuneTennis 3.5-4.0+",
                                       "FortuneTennis 4.0",
                                       "FortuneTennis 4.5",
                                       "FortuneTennis 5.0",
                                       ]
    @State private var newClassName = ""
    @State private var selectedClass = DEFAULT_CREATE_CLASS_OPTION

    @State private var showAlert = false // Alert state

    let numberPlayersPickerList = Array(4...10) // Example range from 1 to 10
    
    let timePerRoundPickerList = Array(1...30)
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Create A Game")
                    .font(.title)
                HStack {
                    Text("Name of Class:")
                    Picker("Select an option", selection: $selectedClass) {
                        ForEach(classOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle()) // Set the style of the Picker
                }
                if selectedClass == DEFAULT_CREATE_CLASS_OPTION {
                    TextField(
                        "Enter Class Name",
                        text: $newClassName
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width:300)
                }
                if selectedClass != DEFAULT_CREATE_CLASS_OPTION {
                    NavigationLink(destination: SessionOptionSelect(selectedTennisClass: $selectedClass)) {
                        Text("Create Session")
                    }
                    .buttonStyle(.borderedProminent)
                 } else if selectedClass == DEFAULT_CREATE_CLASS_OPTION && !newClassName.isEmpty {
                    NavigationLink(destination: SessionOptionSelect(selectedTennisClass: $newClassName)) {
                        Text("Create Session")
                    }
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
            }
        }
    }
}

#Preview {
    TennisClassSelect()
}
