import SwiftUI
import AVFoundation

struct SpeechDemoView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(AIService.self) private var aiService
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @StateObject private var speech = SpeechRecognizer()
    @State private var recorder = AudioRecorder()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isSessionActive = false

    var body: some View {
        VStack(spacing: 25) {
            headerView
            
            if !isSessionActive {
                welcomeCard
            } else {
                activeSessionView
            }

            if aiService.simulationTerminee {
                resultsDashboard
            }
        }
        .padding(40)
        .glassBackgroundEffect()
        .onChange(of: speech.finalResultReceived) { _, finished in
            if finished && !speech.recognizedText.isEmpty {
                aiService.sayResponse(to: speech.recognizedText)
                speech.finalResultReceived = false
            }
        }
    }

    // MARK: - LOGIQUE AUDIO SÉCURISÉE
    
    private func startFullExperience() {
        Task {
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker])
            try? session.setActive(true)

            let result = await openImmersiveSpace(id: appModel.immersiveSpaceID)
            if result == .opened {
                isSessionActive = true
                aiService.resetInterview()
                try? await Task.sleep(for: .seconds(0.8))
                recorder.startRecording()
                aiService.sayResponse(to: "bonjour")
            }
        }
    }

    private func playRecording(url: URL) {
        // 1. Vérification de l'intégrité du fichier
        let fileManager = FileManager.default
        if let attrs = try? fileManager.attributesOfItem(atPath: url.path),
           let size = attrs[.size] as? UInt64, size == 0 {
            print("❌ Erreur : Le fichier est vide.")
            return
        }

        Task {
            let session = AVAudioSession.sharedInstance()
            do {
                // 2. Libération totale de la session précédente
                try session.setActive(false, options: .notifyOthersOnDeactivation)
                try session.setCategory(.playback, mode: .spokenAudio)
                try session.setActive(true)
                
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.volume = 1.0
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                print("✅ Lecture en cours")
            } catch {
                print("❌ Erreur lecture: \(error.localizedDescription)")
            }
        }
    }

    private func exitExperience() {
        Task {
            recorder.stopRecording()
            // On attend que le système relâche les ressources micro
            try? await Task.sleep(for: .seconds(0.5))
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            await dismissImmersiveSpace()
            isSessionActive = false
        }
    }

    // MARK: - COMPOSANTS UI (Simplifiés pour l'envoi)

    private var headerView: some View {
        VStack(spacing: 5) {
            Text("BPCE TRAINING").font(.caption).tracking(3).foregroundColor(.secondary)
            Text("Simulation d'entretien").font(.largeTitle).bold()
        }
    }

    private var welcomeCard: some View {
        VStack(spacing: 30) {
            Image(systemName: "visionpro").font(.system(size: 60)).foregroundColor(.purple)
            Button(action: { startFullExperience() }) {
                Label("Démarrer la session 3D", systemImage: "play.fill").padding()
            }.buttonStyle(.borderedProminent)
        }.frame(maxWidth: 500).padding(50).background(.ultraThinMaterial).cornerRadius(30)
    }

    private var activeSessionView: some View {
        VStack(spacing: 25) {
            GroupBox(label: Label("Transcription", systemImage: "quote.bubble.fill")) {
                Text(speech.recognizedText.isEmpty ? "L'IA vous écoute..." : speech.recognizedText)
                    .font(.title3).frame(maxWidth: .infinity, alignment: .leading).padding()
            }.frame(height: 150)

            HStack(spacing: 40) {
                Button(action: { try? speech.startListening() }) {
                    Image(systemName: "mic.circle.fill").font(.system(size: 50))
                }.disabled(speech.isListening)

                Button(action: { speech.stopListening() }) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 50)).foregroundColor(.green)
                }.disabled(!speech.isListening)
            }
        }
    }

    private var resultsDashboard: some View {
        VStack(spacing: 20) {
            Text("Bilan de Performance").font(.title).bold()
            
            HStack(spacing: 15) {
                feedbackColumn(title: "Points Parfaits", points: aiService.rapportFinal?.pointsPositifs ?? [], color: .green)
                feedbackColumn(title: "À Améliorer", points: aiService.rapportFinal?.pointsAmelioration ?? [], color: .orange)
            }

            HStack(spacing: 20) {
                if let url = recorder.recordingURL {
                    Button("Réécouter") { playRecording(url: url) }.buttonStyle(.bordered)
                }
                Button("Terminer") { exitExperience() }.buttonStyle(.borderedProminent)
            }
        }.padding(30).background(.regularMaterial).cornerRadius(30)
    }

    private func feedbackColumn(title: String, points: [String], color: Color) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline).foregroundColor(color)
            Divider()
            ForEach(points, id: \.self) { Text($0).font(.caption).padding(.vertical, 2) }
        }.padding().frame(maxWidth: .infinity, alignment: .topLeading).background(color.opacity(0.05)).cornerRadius(10)
    }
}
