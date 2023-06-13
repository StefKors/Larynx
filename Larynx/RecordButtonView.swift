//
//  RecordButtonView.swift
//  Larynx
//
//  Created by Stef Kors on 09/06/2023.
//

import SwiftUI

struct RecordButtonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AudioRecorder.self) private var audioRecorder

    var body: some View {
        RoundedRectangle(cornerRadius: audioRecorder.status == .stopped ? 400 : 15, style: .continuous)
            .foregroundStyle(audioRecorder.status == .paused ? Color.secondary : Color.red)
            .aspectRatio(contentMode: .fill)
            .frame(width: 75, height: 75)
        // .transition(.identity)
            .onTapGesture {
                if audioRecorder.status == .recording {
                    if let url = self.audioRecorder.stopRecording() {
                        do {
                            let data = try Data(contentsOf: url)
                            addItem(data: data)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    self.audioRecorder.startRecording()
                }
            }
    }

    private func addItem(data: Data) {
        withAnimation {
            print("adding data")
            let newRecording = Recording(createdAt: Date(), data: data)
            modelContext.insert(newRecording)
        }
    }
}

#Preview {
    RecordButtonView()
}
