//AudioRecorder.swift

//Created by BLCKBIRDS on 28.10.19.
//Visit www.BLCKBIRDS.com for more.

import Foundation
import SwiftUI
import AVFoundation
import Combine
import Observation

enum RecordingStatus: String {
    case paused
    case stopped
    case recording
}


@Observable class AudioRecorder {

    init() {
        // fetchRecordings()
    }

    var audioRecorder: AVAudioRecorder? = nil

    var timer: Timer? = nil

    var waveData: [Float] = [
        0.58279,
        0.5517001,
        0.4868758,
        0.42140305,
        0.34742197,
        0.29337305,
        0.23554838,
        0.18917833,
        0.20584933,
        0.20517829,
        0.19761492,
        0.18393315,
        0.16070476,
        0.19380987,
        0.18215047,
        0.22915293,
        0.2223225,
        0.20995906,
        0.21535343,
        0.21237196,
        0.22728816,
        0.21367633,
        0.20140871,
        0.20018585,
        0.19536097,
        0.19239143,
        0.17856483,
        0.14788254,
        0.17913625,
        0.24830516,
        0.23075086,
        0.18742979,
        0.15720275,
        0.135945,
        0.115895815,
        0.115389585,
        0.10548503,
        0.12751615,
        0.11020595,
        0.0986685,
        0.095158994,
        0.19774084,
        0.23298162,
        0.24049324,
        0.21649364,
        0.18670157,
        0.16576438,
        0.13474016,
        0.14218311,
        0.1758967,
        0.14221528,
        0.1380464,
        0.17071505,
        0.15552913,
        0.13084006,
        0.12924014,
        0.11431522,
        0.13116233,
        0.11814214,
        0.10062109,
        0.2688127,
        0.23943134,
        0.21502066,
        0.16700119,
        0.13830847,
        0.11249664,
        0.09580562,
        0.095182665,
        0.099109694,
        0.08658831,
        0.08675075,
        0.09688744,
        0.086340256,
        0.16899426,
        0.3354745,
        0.3146799,
        0.2682269,
        0.21267708,
        0.17002511,
        0.13300444,
        0.10851091,
        0.09026347,
        0.09371074,
        0.08841256,
        0.09043728,
        0.07937989,
        0.25394768,
        0.44318858,
        0.395693,
        0.33417007,
        0.2669284,
        0.22670445,
        0.20272739,
        0.21808165,
        0.18980372,
        0.15276536,
        0.16037723,
        0.13878311,
        0.11376496,
        0.09579445,
        0.08772149,
        0.080957115,
        0.09387027,
        0.081306264,
        0.08755804,
        0.07677362,
        0.099313736,
        0.20855245,
        0.40456572,
        0.33307353,
        0.28086543,
        0.21836485,
        0.17248887,
        0.13654423,
        0.10936382,
        0.09098671,
        0.08809527,
        0.2758242,
        0.30787182,
        0.24635783,
        0.19870491,
        0.15696982,
        0.12292905,
        0.10258627,
        0.14801171,
        0.16591547,
        0.27162626,
        0.21356575,
        0.2384881,
        0.19084911,
        0.31987676,
        0.26907256,
        0.22473258,
        0.1879861,
        0.15722758,
        0.1336965,
        0.114373185,
        0.09969212,
        0.17573684,
        0.24927555,
        0.22051416,
        0.1936517,
        0.266244,
        0.2222761,
        0.19282615,
        0.1727133,
        0.1426153,
        0.12399864,
        0.10706391,
        0.10208752,
        0.088573605,
        0.09406498,
        0.08568666,
        0.08231035,
        0.10132256,
    ]

    var status: RecordingStatus = .stopped

    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }

        let documentPath = FileManager.default.temporaryDirectory
        let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            guard let audioRecorder else { return }
            audioRecorder.record()
            audioRecorder.isMeteringEnabled = true

            withAnimation(.easeInOut) {
                status = .recording
            }

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timerval in
                self.audioRecorder?.updateMeters()
                let averagePower = self.audioRecorder?.averagePower(forChannel: 0) ?? -100
                let minDecibels: Float = -80.0
                if averagePower < minDecibels {
                    withAnimation(.spring()) {
                        self.waveData.append(0)
                    }
                } else if averagePower >= 0 {
                    withAnimation(.spring()) {
                        self.waveData.append(1)
                    }
                } else {
                    let minAmp = pow(10.0, minDecibels * 0.05)
                    let inverse = 1.0/(1.0 - minAmp)
                    let amp = pow(10.0, averagePower * 0.05)
                    let adjAmp = (amp - minAmp) * inverse
                    let level = powf(Float(adjAmp), 1.0 / 2.0) * 2

                    withAnimation(.spring()) {
                        self.waveData.append(level)
                    }
                }
            })
        } catch {
            print("Could not start recording")
        }
    }

    func pauseRecording() {
        timer?.invalidate()
        audioRecorder?.pause()
        withAnimation(.easeInOut) {
            status = .paused
        }
    }

    func stopRecording() -> URL? {
        timer?.invalidate()
        audioRecorder?.stop()
        withAnimation(.easeInOut) {
            status = .stopped
        }

        return audioRecorder?.url
        // fetchRecordings()
    }

    // func fetchRecordings() {
    //     recordings.removeAll()
    // 
    //     let fileManager = FileManager.default
    //     let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //     let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
    //     for audio in directoryContents {
    //         let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
    //         recordings.append(recording)
    //     }
    // 
    //     recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
    // }

}
