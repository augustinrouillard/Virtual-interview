import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(AIService.self) private var aiService

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E8EAF6"), Color(hex: "F5F5F7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            if aiService.simulationTerminee {
                SpeechDemoView()
            } else {
                switch appModel.interviewState {
                case .welcome: WelcomeView()
                case .recording: RecordingView()
                case .finished: DebriefView()
                }
            }
        }
        .animation(.easeInOut, value: appModel.interviewState)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
