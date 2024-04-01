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
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
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
    var activePlayer: Bool
    @StateObject var stopwatchViewModel = StopwatchViewModel()

}

struct PlayerTimers: View {
    @Binding var selectedTennisClass: String
    @Binding var numPlayers : Int

    @StateObject var stopwatchViewModelA = StopwatchViewModel()
    @StateObject var stopwatchViewModelB = StopwatchViewModel()

    @State private var rows: [RowItem] = [
        RowItem(textFieldText: "", activePlayer: false),
        RowItem(textFieldText: "", activePlayer: false),
        RowItem(textFieldText: "", activePlayer: false)
    ]
    
    @State private var playerSelectCount = 0;

    var body: some View {
        
        Text("Selected option: \(selectedTennisClass) \(numPlayers)")
            .padding()
        
        Text(String(format: "%.2f", stopwatchViewModelA.elapsedTime))
            .font(.largeTitle)
            .padding()
        
        HStack {
            Button(action: {
                if stopwatchViewModelA.isRunning {
                    stopwatchViewModelA.stop()
                } else {
                    stopwatchViewModelA.start()
                }
            }) {
                Text(stopwatchViewModelA.isRunning ? "Stop" : "Start")
                    .padding()
            }
            
            Button(action: {
                stopwatchViewModelA.reset()
            }) {
                Text("Reset")
                    .padding()
            }
        }
        
        Text(String(format: "%.2f", stopwatchViewModelB.elapsedTime))
            .font(.largeTitle)
            .padding()
        
        HStack {
            Button(action: {
                if stopwatchViewModelB.isRunning {
                    stopwatchViewModelB.stop()
                } else {
                    stopwatchViewModelB.start()
                }
            }) {
                Text(stopwatchViewModelB.isRunning ? "Stop" : "Start")
                    .padding()
            }
            
            Button(action: {
                stopwatchViewModelB.reset()
            }) {
                Text("Reset")
                    .padding()
            }
        }

        
        VStack {
            List(rows) { row in
                Text(String(format: "%.2f", row.stopwatchViewModel.elapsedTime))
                    .padding()

                HStack {
                    TextField("Enter text", text: self.binding(for: row))
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        // Change color logic here
                        self.toggleActivePlayer(for: row)

                    }) {
                        Text(row.stopwatchViewModel.isRunning ? "Stop" : "Start")
                            .padding()
                            .background(buttonColor(for: row))
                            .foregroundColor(.white)
                            .cornerRadius(8)

                    }
                    .padding(.trailing)
                }
                .onReceive(row.stopwatchViewModel.$elapsedTime) { elapsedTime in
                    // Handle the received elapsedTime for each row
                    print("Elapsed time for row \(row.id): \(elapsedTime)")
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
        rows[index].activePlayer.toggle()
        playerSelectCount += rows[index].activePlayer ? 1 : -1
        if rows[index].activePlayer {
            rows[index].stopwatchViewModel.start()
        } else {
            rows[index].stopwatchViewModel.stop()
            rows[index].stopwatchViewModel.reset()

        }
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
        

