//
//  RecordingView.swift
//  Larynx
//
//  Created by Stef Kors on 07/06/2023.
//

import DSWaveformImageViews
import SwiftUI

struct RecordingView: View {
    @Environment(AudioRecorder.self) private var audioRecorder


    var body: some View {
        NavigationView {
            VStack {
                RecordingsList()
                WaveformLiveCanvas(samples: audioRecorder.waveData)
                if audioRecorder.recording == false {
                    Button(action: {print(self.audioRecorder.startRecording())}) {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    }
                } else {
                    Button(action: {self.audioRecorder.stopRecording()}) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitle("Voice recorder")
        }
    }
}

#Preview {
    RecordingView()
}
