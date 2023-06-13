//
//  TouchDownAndPauseModifier.swift
//  Larynx
//
//  Created by Stef Kors on 09/06/2023.
//

import SwiftUI

struct TouchDownAndPauseModifier: ViewModifier {
    @Environment(AudioRecorder.self) private var audioRecorder
    @State private var tapped: Bool = false

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !self.tapped {
                        self.tapped = true
                        audioRecorder.pauseRecording()
                    }
                }
                .onEnded { _ in
                    self.tapped = false
                    audioRecorder.startRecording()
                })
    }
}

extension View {
    func touchDownAndPauseModifier() -> some View {
        modifier(TouchDownAndPauseModifier())
    }
}

#Preview {
    Text("Hello, world!")
        .modifier(TouchDownAndPauseModifier())
}
