//
//  LarynxApp.swift
//  Larynx
//
//  Created by Stef Kors on 07/06/2023.
//

import SwiftUI
import SwiftData

@main
struct LarynxApp: App {
    @State var audioRecorder = AudioRecorder()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(audioRecorder)
        }
        .modelContainer(for: Item.self)
    }
}
