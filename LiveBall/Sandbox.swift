//
//  Sandbox.swift
//  TennisApp
//
//  Created by Yee on 4/1/24.
//

import SwiftUI
import AVKit



struct Sandbox: View {
    @State private var testClassOptions : [String] = [DEFAULT_CREATE_CLASS_OPTION, "Test Ben"]
    @State private var testSelectedClass = ""



    var body: some View {
        VStack {
            Text("Hello")
            Picker("Select an option", selection: $testSelectedClass) {
                ForEach(testClassOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            
        }

    }

}


struct Sandbox_Previews: PreviewProvider {
    static var previews: some View {
        Sandbox()
    }
}
