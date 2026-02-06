import SwiftUI
import AVFoundation

struct DebriefView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(AIService.self) private var aiService
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 25) {
            Text("Bilan de la performance")
                .font(.extraLargeTitle)
            
            if let rapport = aiService.rapportFinal {
                HStack(spacing: 30) {
                    ScoreTile(title: "Relationnel", score: rapport.scoreRelationnel, color: .purple)
                    ScoreTile(title: "Technique", score: rapport.scoreTechnique, color: .blue)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Points abordés :").bold()
                    ForEach(rapport.pointsPositifs, id: \.self) { pt in
                        Label(pt, systemImage: "checkmark.circle.fill").foregroundColor(.green)
                    }
                }
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(15)
            }

            // RÉÉCOUTE AUDIO
            if let url = appModel.recordedAudioURL {
                Button(action: {
                    audioPlayer = try? AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                }) {
                    Label("Réécouter l'entretien", systemImage: "play.fill")
                        .controlSize(.large)
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Nouvel Entraînement") {
                aiService.resetInterview()
                appModel.resetInterview()
            }
            .buttonStyle(.plain)
            .padding(.top)
        }
        .padding(50)
        .frame(width: 600)
    }
}

struct ScoreTile: View {
    let title: String
    let score: Int
    let color: Color
    var body: some View {
        VStack {
            Text(title).font(.headline)
            Text("\(score)/10")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(color)
        }
        .frame(width: 150, height: 120)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
