import Foundation
import Speech
import AVFoundation
import Combine // <--- CRUCIAL pour @Published

@MainActor
class SpeechRecognizer: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var isListening: Bool = false
    @Published var finalResultReceived: Bool = false
    
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))

    func startListening() throws {
        // Reset
        task?.cancel()
        task = nil
        recognizedText = ""
        isListening = true
        finalResultReceived = false
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        request = SFSpeechAudioBufferRecognitionRequest()
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        task = recognizer?.recognitionTask(with: request!) { result, error in
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
                if result.isFinal { self.finalResultReceived = true }
            }
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        isListening = false
    }
}
