import SwiftUI

struct RecordingView: View {
    // On récupère les instances globales via l'environnement
    @Environment(AppModel.self) private var appModel
    @Environment(AIService.self) private var aiService
    
    // Services locaux pour la vue
    @StateObject private var speech = SpeechRecognizer()
    @State private var recorder = AudioRecorder()
    
    // Timer pour l'affichage de la durée (optionnel mais recommandé)
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0

    var body: some View {
        VStack(spacing: 30) {
            Text("Entretien en cours...")
                .font(.largeTitle)
                .bold()
            
            // Affichage du temps écoulé
            Text(timeString(from: elapsedTime))
                .font(.system(.title, design: .monospaced))
                .foregroundColor(.red)

            // Zone de transcription
            GroupBox(label: Label("Transcription en temps réel", systemImage: "mic.fill")) {
                ScrollView {
                    Text(speech.recognizedText.isEmpty ? "Parlez, je vous écoute..." : speech.recognizedText)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(height: 150)
            }

            Button(action: {
                stopInterview()
            }) {
                Label("Terminer l'entretien", systemImage: "stop.fill")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .buttonStyle(.plain)
        }
        .padding(40)
        .onAppear {
            startInterview()
        }
        .onChange(of: speech.finalResultReceived) { _, finished in
            // Correction : On utilise l'instance injectée aiService
            if finished && !speech.recognizedText.isEmpty {
                aiService.sayResponse(to: speech.recognizedText)
                // On réinitialise pour la prochaine phrase
                speech.finalResultReceived = false
            }
        }
    }

    // MARK: - Logique de contrôle
    
    private func startInterview() {
        // Lancer l'enregistrement audio (le fichier .m4a)
        recorder.startRecording()
        
        // Lancer la reconnaissance vocale (le texte)
        try? speech.startListening()
        
        // Démarrer le chrono
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    private func stopInterview() {
        timer?.invalidate()
        speech.stopListening()
        recorder.stopRecording()
        
        // Mise à jour de l'AppModel avec les données de AudioRecorder
        appModel.recordedAudioURL = recorder.recordingURL
        appModel.recordingDuration = elapsedTime
        
        // Navigation vers l'écran de bilan
        appModel.interviewState = .finished
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
