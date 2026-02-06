import Foundation
import Speech
import AVFoundation
import Combine

@MainActor
final class SpeechRecognizer: ObservableObject {
    @Published var isAuthorized: Bool = false
    @Published var isListening: Bool = false
    @Published var finalResultReceived: Bool = false
    @Published var recognizedText: String = ""

    private let speechRecognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?

    init(locale: Locale = Locale(identifier: "fr-FR")) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
    }

    func requestAuthorization() async {
        let status = await withCheckedContinuation { (continuation: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                continuation.resume(returning: authStatus)
            }
        }
        self.isAuthorized = (status == .authorized)
    }

    func startListening() throws {
        guard !isListening else { return }
        
        // Reset propre
        recognizedText = ""
        finalResultReceived = false

        let audioSession = AVAudioSession.sharedInstance()
        
        // Correction pour Vision Pro : .playAndRecord est indispensable pour que l'IA puisse parler après.
        // On utilise le mode .default pour éviter les erreurs de "lookup failed" sur les sessions proxy.
        // Remplace l'ancienne ligne par celle-ci :
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Sécurité hardware : vider le tap avant d'en remettre un
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isListening = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let text = result.bestTranscription.formattedString
                Task { @MainActor in
                    self.recognizedText = text
                    
                    // GESTION DU SILENCE (L'IA se déclenche 1.5s après la fin de ta parole)
                    self.silenceTimer?.invalidate()
                    self.silenceTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        Task { @MainActor in
                            if self.isListening {
                                self.stopListening()
                                self.finalResultReceived = true // Ceci déclenche l'IA dans la View
                            }
                        }
                    }

                    if result.isFinal {
                        self.finalResultReceived = true
                    }
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                Task { @MainActor in
                    if self.isListening {
                        self.stopListening()
                    }
                }
            }
        }
    }

    func stopListening() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionTask = nil
        recognitionRequest = nil
        isListening = false
        
        // IMPORTANT : On ne fait PAS try audioSession.setActive(false) ici.
        // Sinon, le haut-parleur se coupe et AIService ne pourra pas parler.
    }
}
