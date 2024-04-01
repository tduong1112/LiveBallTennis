//
//  PlayerTimers.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

struct RowItem: Identifiable {
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

    @State private var rows: [RowItem] = {
        var array = [RowItem]()
        for _ in 0..<5 {
            array.append(RowItem())
        }
        return array
    }()
    @State private var playerSelectCount = 0;

    var body: some View {
        
        Text("Selected option: \(selectedTennisClass) \(numPlayers)")
            .padding()

        VStack {
            List(rows) { row in
                HStack {
                    TextField("Enter text", text: self.binding(for: row))
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        // Change color logic here
                        self.toggleActivePlayer(for: row)

                    }) {
                        Text("Row \(row.activePlayer)")
                            .padding()
                            .background(buttonColor(for: row))
                            .foregroundColor(.white)
                            .cornerRadius(2)

                    }
                    .padding(.trailing)
                }
            }
        }


    }
    private func binding(for row: RowItem) -> Binding<String> {
        guard let index = rows.firstIndex(where: { $0.id == row.id }) else {
            fatalError("Can't find row in array")
        }
        return $rows[index].textFieldText
    }
    
    private func toggleActivePlayer(for row: RowItem) {
        guard let index = rows.firstIndex(where: { $0.id == row.id }) else {
            return
        }
        if rows[index].textFieldText.isEmpty{
            return
        }
        rows[index].activePlayer.toggle()
        playerSelectCount += rows[index].activePlayer ? 1 : -1
    }
    
    // Toggling Logic for the color. Selects which color based on that row's active Status
    private func buttonColor(for row: RowItem) -> Color {
        guard let index = rows.firstIndex(where: { $0.id == row.id }) else {
            return .blue
        }
        return rows[index].activePlayer ? .red : .blue
    }

    
}

#Preview {
    PlayerTimers(
        selectedTennisClass: .constant("Option A"),
        numPlayers: .constant(5)
    )
}
        

