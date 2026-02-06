import SwiftUI

struct SpeechDemoView: View {
    @StateObject private var speech = SpeechRecognizer()
    @State private var hasSaidBonjour: Bool = false
    @State private var isRequestingAuth: Bool = true
    private let aiService = AIService()

    var body: some View {
        VStack(spacing: 24) {
            Text("Reconnaissance: dire \"bonjour\"")
                .font(.title2)

            Toggle(isOn: $hasSaidBonjour) {
                Text("J'ai dit bonjour")
            }
#if os(visionOS)
            // .checkbox n'est pas disponible sur visionOS
            .toggleStyle(.switch)
#else
            .toggleStyle(.checkbox)
#endif
            .disabled(true)

            GroupBox("Transcription en direct") {
                ScrollView {
                    Text(speech.recognizedText.isEmpty ? "(en attente...)" : speech.recognizedText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                .frame(height: 120)
            }

            HStack(spacing: 16) {
                Button {
                    try? speech.startListening()
                } label: {
                    Label("Démarrer l'écoute", systemImage: "mic.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!speech.isAuthorized || speech.isListening)

                Button {
                    speech.stopListening()
                } label: {
                    Label("Arrêter", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
                .disabled(!speech.isListening)
            }

            if !speech.isAuthorized {
                Text("Autorisez la reconnaissance vocale et le micro dans Réglages > Confidentialité.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        // Ajoute ce bloc après ton premier .onChange
        .onChange(of: speech.finalResultReceived) { _, finished in
            if finished {
                // L'utilisateur a fini de parler, l'IA répond
                aiService.sayResponse(to: speech.recognizedText)
                
                // On réinitialise l'état pour la prochaine fois
                speech.finalResultReceived = false
            }
        }
        .task {
            if isRequestingAuth {
                await speech.requestAuthorization()
                isRequestingAuth = false
            }
        }
        .navigationTitle("Micro: Bonjour")
    }
}

#Preview {
    SpeechDemoView()
}
