//
//  PlayerTimers.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

struct PlayerItem: Identifiable {
    var id = UUID()
    var textFieldText: String
    var activePlayer: Bool
    
    init() {
        self.textFieldText = ""
        self.activePlayer = false
    }

}

struct PlayerTimers: View {
    @Binding var selectedTennisClass: String
    @Binding var numPlayers : Int

    @State private var playerRows: [PlayerItem] = {
        var array = [PlayerItem]()
        for _ in 0..<5 {
            array.append(PlayerItem())
        }
        return array
    }()
    
    @State private var playerSelectCount = 0;

    var body: some View {
        
        Text("Selected option: \(selectedTennisClass) \(numPlayers)")
            .padding()

        VStack {
            List(playerRows) { PlayerItem in
                HStack {
                    TextField("Enter text", text: self.binding(for: PlayerItem))
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        // Change color logic here
                        self.toggleActivePlayer(for: PlayerItem)

                    }) {
                        Text("Row \(PlayerItem.activePlayer)")
                            .padding()
                            .background(buttonColor(for: PlayerItem))
                            .foregroundColor(.white)
                            .cornerRadius(2)

                    }
                    .padding(.trailing)
                }
            }
        }


    }
    private func binding(for PlayerItem: PlayerItem) -> Binding<String> {
        guard let index = playerRows.firstIndex(where: { $0.id == PlayerItem.id }) else {
            fatalError("Can't find PlayerItem in array")
        }
        return $playerRows[index].textFieldText
    }
    
    private func toggleActivePlayer(for PlayerItem: PlayerItem) {
        guard let index = playerRows.firstIndex(where: { $0.id == PlayerItem.id }) else {
            return
        }
        // Make sure an empty name is not submitted
        if playerRows[index].textFieldText.isEmpty{
            return
        }
        playerRows[index].activePlayer.toggle()
        playerSelectCount += playerRows[index].activePlayer ? 1 : -1
    }
    
    
    // Toggling Logic for the color. Selects which color based on that PlayerItem's active Status
    private func buttonColor(for PlayerItem: PlayerItem) -> Color {
        guard let index = playerRows.firstIndex(where: { $0.id == PlayerItem.id }) else {
            return .blue
        }
        return playerRows[index].activePlayer ? .red : .blue
    }

    
}

#Preview {
    PlayerTimers(
        selectedTennisClass: .constant("Option A"),
        numPlayers: .constant(5)
    )
}
        

