//
//  AudioWaveView.swift
//  Larynx
//
//  Created by Stef Kors on 09/06/2023.
//

import SwiftUI

struct AudioWaveView: View {
    @Environment(AudioRecorder.self) private var audioRecorder

    var barColor: Color {
        audioRecorder.status == .recording ? .red : .secondary
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.systemGroupedBackground

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 3) {
                        ForEach(audioRecorder.waveData, id: \.self) { section in
                            RoundedRectangle(cornerRadius: 20)
                                .fill(barColor)
                                .frame(width: max(CGFloat(section * 150), 3), height: 3)
                                .transition(.scale.combined(with: .opacity).combined(with: .move(edge: .bottom)))
                        }

                    }
                    .frame(width: geo.size.width)
                    .padding(.bottom)
                }
                .defaultScrollAnchor(.bottom)

            }
            .frame(alignment: .bottom)
            .ignoresSafeArea(.all, edges: .top)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
            .fixedSize()
        }
    }
}

#Preview {
    AudioWaveView()
}
