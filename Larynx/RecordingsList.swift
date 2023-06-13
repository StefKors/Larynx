import SwiftUI
import SwiftData

struct RecordingsList: View {
    @Query private var recordings: [Recording]

    var body: some View {
        List {
            ForEach(recordings, id: \.createdAt) { recording in
                RecordingRow(createdAt: recording.createdAt)
            }
        }
    }
}

struct RecordingRow: View {
    var createdAt: Date

    var body: some View {
        HStack {
            Text("\(createdAt.formatted())")
            Spacer()
        }
    }
}

struct RecordingsList_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsList()
    }
}
