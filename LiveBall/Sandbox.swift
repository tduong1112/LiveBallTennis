//
//  Sandbox.swift
//  TennisApp
//
//  Created by Yee on 4/1/24.
//

import SwiftUI
import AVKit




struct Sandbox: View {
    @StateObject var pathState = PathState()
    var body: some View {
        Text("Hello")
//      NavigationStack(path: $pathState.path) {
//        Image(systemName: "figure.fall")
//          .imageScale(.large)
//          .foregroundStyle(.tint)
//          .navigationDestination(for: PathState.Destination.self) { destination in
//            switch destination {
//            case .first:
//              FirstView()
//            case .second:
//              SecondView()
//            case .third:
//              ThirdView()
//            }
//          }
//        NavigationLink("Go to FirstView", value: PathState.Destination.first)
//      }
//      .padding()
//      .overlay(alignment: .top) {
//        Text("Navigation Path: \(pathState.path.map(\.rawValue).debugDescription)")
//      }
//      .environmentObject(pathState)
    }
}
////------------------FirstView------------------
//struct FirstView: View {
//  var body: some View {
//    NavigationLink("Go to SecondView", value: PathState.Destination.second)
//  }
//}
//
////-----------------SecondView------------------
//struct SecondView: View {
//  var body: some View {
//    NavigationLink("Go to ThirdView", value: PathState.Destination.third)
//  }
//}
//
////------------------ThirdView------------------
//struct ThirdView: View {
//  @EnvironmentObject var pathState: PathState
//  var body: some View {
//    Text("RootPath: \(pathState.path.count)")
//    Button(action: {
//      pathState.path = [] // take everything off the navigation stack
//    }, label: {
//      Text("Go to ContentView")
//    })
//  }
//}

#Preview {
    Sandbox()
}
