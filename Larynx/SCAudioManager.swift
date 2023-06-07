//
//  SCAudioManager.m
//  soundcard
//
//  Created by Dennis Schmidt on 27.09.13.
//  Copyright (c) 2013 soundcard.io. All rights reserved.
//

import Foundation
import DSWaveformImage
import DSWaveformImageViews
import AVFAudio
import AVFoundation

class SCAudioManager: AVCaptureFileOutput {

    private var recorder:AVAudioRecorder!
    private var player:AVAudioPlayer!
    private var updateProgressIndicatorTimer:Timer!
    private var currentRecordedAudioFilename:String!

    let kMinRecordingTime: TimeInterval = 0.3
    let kMaxRecordingTime: TimeInterval = 90.0
    let kSCTemporaryRecordedAudioFilename:String = "audio_temp.m4a"
    let kSCDownloadedAudioFilename:String = "loaded_sound.m4a"
    let kSCRecordingsFolderName:String = "recordings"
    var currentRecordingTime: CGFloat = 0.0

    // MARK: -
    // MARK: Public Interface
    // MARK: Helper methods

    func recordingsFolderURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func recordedAudioFileURL() -> URL {
        return self.recordingsFolderURL().appending(path: self.currentRecordedAudioFilename)
    }

    func downloadedAudioFileURL() -> URL {
        return self.recordingsFolderURL().appending(path: kSCDownloadedAudioFilename)
    }

    // MARK: Audio Recording methods

    func recording() -> Bool {
        return self.recorder.isRecording
    }

    func startRecording() {
        if !self.recorder.isRecording {
            // Stop the audio player before recording
            if self.player.isPlaying {
                self.player.stop()
                self.updateProgressIndicatorTimer.invalidate()
            }

            let session:AVAudioSession = AVAudioSession.sharedInstance()
            try? session.setActive(true)

            // Start recording
            self.currentRecordingTime = 0.0
            self.recorder.record()
            self.updateProgressIndicatorTimer.invalidate()
            self.updateProgressIndicatorTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                self.recordingStatusDidUpdate()
            })
            // self.updateProgressIndicatorTimer = Timer.scheduledTimerWithTimeInterval(0.01, target:self, selector:Selector("recordingStatusDidUpdate"), userInfo:nil, repeats:true)
        }
    }

    func lastAveragePower() -> Float {
        return self.recorder.averagePower(forChannel: 0)
    }

    override func stopRecording() {
        if self.recorder.isRecording {
            self.recorder.stop()

            let audioSession:AVAudioSession! = AVAudioSession.sharedInstance()
            try? audioSession.setActive(false)

            self.updateProgressIndicatorTimer.invalidate()
        }
    }

    func reset() {
        self.player.stop()
        self.stopRecording()
        self.recorder.prepareToRecord()
        self.currentRecordingTime = 0.0
    }

    func setRecordingToBeSentAgainFromAudioAtURL(audioURL:NSURL!) {
        self.currentRecordingTime = kMinRecordingTime + 1 // just something to say we captured enough
        self.copyTemporaryAudioFileToPersistentLocation(audioURL: audioURL)
        self.recordingDelegate.audioManager(self, didFinishRecordingSuccessfully:true)
    }

    // MARK: -
    // MARK: Audio Recording / Playback Feedback methods

    func recordingStatusDidUpdate() {
        self.currentRecordingTime = self.recorder.currentTime
        let progress:CGFloat = fmax(0, fmin(1, self.currentRecordingTime / kMaxRecordingTime))

        self.recorder.updateMeters()
        self.recordingDelegate.audioManager(self, didUpdateRecordProgress:progress)

        if progress >= 1.0 {
            self.stopRecording()
        }
    }

    func playbackStatusDidUpdate() {
        let currentPlayTime:CGFloat = self.player.currentTime / (self.player.duration as! CGFloat)
        let progress:CGFloat = fmax(0, fmin(1, currentPlayTime))
        self.playbackDelegate.audioManager(self, didUpdatePlayProgress:progress)
    }

    func hasCapturedSufficientAudioLength() -> Bool {
        return self.currentRecordingTime > kMinRecordingTime
    }

    // MARK: -
    // MARK: Audio Playback methods

    func playAudioFileFromURL(audioURL:NSURL!) {
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, error:nil)
        let audioRouteOverride:UInt32 = kAudioSessionOverrideAudioRoute_Speaker

        // pragma clang diagnostic push
        // pragma clang diagnostic ignored "-Wdeprecated-declarations"
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(`$`(TypeName)), &audioRouteOverride)
        // pragma clang diagnostic pop

        if !self.recorder.isRecording {
            self.updateProgressIndicatorTimer.invalidate()
            self.updateProgressIndicatorTimer = Timer.scheduledTimerWithTimeInterval(0.01, target:self, selector:Selector("playbackStatusDidUpdate"), userInfo:nil, repeats:true)

            self.player = AVAudioPlayer(contentsOf:audioURL as URL, fileTypeHint:nil)
            self.player.delegate = self
            self.player.play()
        }
    }

    func playing() -> Bool {
        return self.player.isPlaying
    }

    func startPlayingRecordedAudio() {
        self.playAudioFileFromURL(audioURL: self.recordedAudioFileURL())
    }

    func stopPlayingRecordedAudio() {
        if self.player.isPlaying {
            self.player.stop()
            self.updateProgressIndicatorTimer.invalidate()
            self.playbackDelegate.audioManager(self, didFinishPlayingSuccessfully:false)
        }
    }

    func playDownloadedAudio() {
        self.playAudioFileFromURL(audioURL: self.downloadedAudioFileURL())
    }

    // MARK: -
    // MARK: AVAudioRecorderDelegate methods

    func audioRecorderDidFinishRecording(avrecorder:AVAudioRecorder!, successfully flag:Bool) {
        self.updateProgressIndicatorTimer.invalidate()

        if self.hasCapturedSufficientAudioLength() {
            self.copyTemporaryAudioFileToPersistentLocation(audioURL: self.temporaryRecordedAudioFileURL())
        }

        self.recordingDelegate.audioManager(self, didFinishRecordingSuccessfully:flag)
    }

    // MARK: -
    // MARK: AVAudioPlayerDelegate methods

    func audioPlayerDidFinishPlaying(player:AVAudioPlayer!, successfully flag:Bool) {
        self.updateProgressIndicatorTimer.invalidate()

        self.playbackDelegate.audioManager(self, didFinishPlayingSuccessfully:flag)
    }

    // MARK: -
    // MARK: Private methods

    func temporaryRecordedAudioFileURL() -> NSURL! {
        let homeDirectory:String! = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).lastObject()
        let pathComponents:[AnyObject]! = [AnyObject].arrayWithObjects(homeDirectory, kSCTemporaryRecordedAudioFilename, nil)
        return NSURL.fileURLWithPathComponents(pathComponents) as NSURL?
    }

    func prepareAudioRecording() {
        // Set the temporary audio file
        let outputFileURL:NSURL! = self.temporaryRecordedAudioFileURL()

        // Setup audio session
        let session:AVAudioSession! = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:nil)

        // Define the recorder setting
        let recordSetting:NSMutableDictionary! = NSMutableDictionary()

        recordSetting.setValue(NSNumber.numberWithInt(kAudioFormatMPEG4AAC), forKey:AVFormatIDKey)
        recordSetting.setValue(NSNumber.numberWithFloat(44100.0), forKey:AVSampleRateKey)
        recordSetting.setValue(NSNumber.numberWithInt(1), forKey:AVNumberOfChannelsKey)

        // Initiate and prepare the recorder
        self.recorder = AVAudioRecorder(URL:outputFileURL as URL, settings:recordSetting, error:nil)
        self.recorder.delegate = self
        self.recorder.isMeteringEnabled = true

        session.requestRecordPermission({ (granted:Bool) in
            self.recordingDelegate.audioManager(self, didAllowRecording:granted)
            self.recorder.prepareToRecord()
        })
    }

    func copyTemporaryAudioFileToPersistentLocation(audioURL:NSURL!) {
        self.currentRecordedAudioFilename = String(format:"%@.m4a", NSUUID().uuidString)
        let recordedAudioData:NSData! = NSData.dataWithContentsOfURL(audioURL as URL)

        NSFileManager.defaultManager.createDirectoryAtPath(self.recordingsFolderURL().path, withIntermediateDirectories:true, attributes:nil, error:nil)
        recordedAudioData.writeToURL(self.recordedAudioFileURL() as URL, atomically:true)
        NSLog("new audio file recorded to %@", self.recordedAudioFileURL())
    }
}
