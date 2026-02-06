import Foundation
import AVFoundation
import Observation

@MainActor
@Observable
class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    var isRecording = false
    var recordingURL: URL?
    private var audioRecorder: AVAudioRecorder?

    func startRecording() {
        AVAudioApplication.requestRecordPermission { granted in
            if granted {
                Task { @MainActor in
                    await self.setupRecording()
                }
            }
        }
    }

    private func setupRecording() async {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documentsPath.appendingPathComponent("interview-\(UUID().uuidString).m4a")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.prepareToRecord()
            
            if audioRecorder?.record() ?? false {
                isRecording = true
                recordingURL = url
                print("✅ Enregistrement démarré")
            }
        } catch {
            print("❌ Erreur recorder: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        audioRecorder?.stop()
        audioRecorder = nil // ⚠️ INDISPENSABLE : Force la finalisation du fichier
        isRecording = false
        print("✅ Fichier audio finalisé et sauvegardé")
    }
}
