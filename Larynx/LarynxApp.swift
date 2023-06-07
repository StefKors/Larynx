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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
