//
//  ContentView.swift
//  Larynx
//
//  Created by Stef Kors on 07/06/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AudioRecorder.self) private var audioRecorder
    @Query private var recordings: [Recording]

    @Namespace var topID
    @Namespace var bottomID

    @State private var isPresented: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                AudioWaveView()
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.red)
                            .frame(height: 1)
                            .padding(.bottom)
                    }
                    .touchDownAndPauseModifier()

                HStack(alignment: .center, spacing: 50) {
                    Button(action: { }) {
                        Image(systemName: "speaker.slash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .clipped()
                            .foregroundColor(.secondary)
                            .padding(12)
                    }

                    RecordButtonView()

                    Button(action: { isPresented.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .clipped()
                            .foregroundColor(.secondary)
                            .padding(12)
                            .overlay(alignment: .topTrailing) {
                                if recordings.count > 0 {
                                    Text(recordings.count.description)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 12, weight: .semibold))
                                        .padding(6)
                                        .background(.red, in: Circle())
                                }
                            }
                    }
                }
                .padding(.top)
                .frame(height: 100, alignment: .center)
            }
            .sheet(isPresented: $isPresented, content: {
                RecordingsList()
                    .navigationTitle("Recordings")
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            })
        }
    }

    private func addItem(data: Data) {
        withAnimation {
            let newRecording = Recording(createdAt: Date(), data: data)
            modelContext.insert(newRecording)
        }
    }
    
    // private func deleteItems(offsets: IndexSet) {
    //     withAnimation {
    //         for index in offsets {
    //             modelContext.delete(recordings[index])
    //         }
    //     }
    // }
}

#Preview {

    ContentView()
        .modelContainer(for: Recording.self, inMemory: true)
}
