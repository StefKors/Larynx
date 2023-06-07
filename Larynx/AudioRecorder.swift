//AudioRecorder.swift

//Created by BLCKBIRDS on 28.10.19.
//Visit www.BLCKBIRDS.com for more.

import Foundation
import SwiftUI
import AVFoundation
import Combine
import Observation


@Observable class AudioRecorder {

    init() {
        fetchRecordings()
    }

    var audioRecorder: AVAudioRecorder? = nil

    var timer: Timer? = nil

    var recordings = [Recording]()

    var waveData: [Float] = []

    var recording = false
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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

            recording = true

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timerval in
                audioRecorder.updateMeters()
                let power = audioRecorder.averagePower(forChannel: 0)
                let linear = 1 - pow(10, power / 20)
                print("update with power \(power) || \(linear)")
                self.waveData.append(linear)
            })
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        timer?.invalidate()
        audioRecorder?.stop()
        recording = false
        fetchRecordings()
    }
    
    func fetchRecordings() {
        recordings.removeAll()
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
            recordings.append(recording)
        }
        
        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
    }
    
}
