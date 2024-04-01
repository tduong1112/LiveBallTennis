//
//  PlayerTimers.swift
//  TennisApp
//
//  Created by Yee on 3/31/24.
//

import SwiftUI

class StopwatchViewModel: ObservableObject {
    @Published var elapsedTime = 0.0
    @Published var isRunning = false
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.elapsedTime += 0.01
        }
        isRunning = true
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0.0
        isRunning = false
    }
}

struct RowItem: Identifiable {
    var id = UUID()
    var textFieldText: String
    var labelText: String
    @StateObject var stopwatchViewModel = StopwatchViewModel()

}

struct PlayerTimers: View {
    @Binding var selectedTennisClass: String
    @Binding var numPlayers : Int

    @StateObject var stopwatchViewModel = StopwatchViewModel()
    @State private var rows: [RowItem] = [
        RowItem(textFieldText: "", labelText: "Row 1"),
        RowItem(textFieldText: "", labelText: "Row 2"),
        RowItem(textFieldText: "", labelText: "Row 3")
    ]
    
    @State private var playerSelectCount = 0;
    @State private var buttonStates: [UUID: Bool] = [:]


    var body: some View {
        
        Text("Selected option: \(selectedTennisClass) \(numPlayers)")
            .padding()
        
        Text(String(format: "%.2f", stopwatchViewModel.elapsedTime))
            .font(.largeTitle)
            .padding()
        
        HStack {
            Button(action: {
                if stopwatchViewModel.isRunning {
                    stopwatchViewModel.stop()
                } else {
                    stopwatchViewModel.start()
                }
            }) {
                Text(stopwatchViewModel.isRunning ? "Stop" : "Start")
                    .padding()
            }
            
            Button(action: {
                stopwatchViewModel.reset()
            }) {
                Text("Reset")
                    .padding()
            }
        }
        VStack {
            List(rows) { row in
                HStack {
                    TextField("Enter text", text: self.binding(for: row))
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        // Change color logic here
                        print("Button pressed for \(row.labelText)")
                        self.toggleButtonColor(for: row)

                    }) {
                        Text(String(format: "%.2f", row.stopwatchViewModel.elapsedTime))
                            .padding()
                            .background(buttonColor(for: row))
                            .foregroundColor(.white)
                            .cornerRadius(8)
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
    
    private func toggleButtonColor(for row: RowItem) {
        guard let index = rows.firstIndex(where: { $0.id == row.id }) else {
            return
        }
        let buttonID = rows[index].id
        buttonStates[buttonID, default: false].toggle()
    }
    
    private func buttonColor(for row: RowItem) -> Color {
        guard let index = rows.firstIndex(where: { $0.id == row.id }) else {
            return .blue
        }
        let buttonID = rows[index].id
        return buttonStates[buttonID, default: false] ? .red : .blue
    }

    
}

#Preview {
    PlayerTimers(
        selectedTennisClass: .constant("Option A"),
        numPlayers: .constant(5)
    )
}
        

