import SwiftUI

@main
struct Virtual_interviewApp: App {
    @State private var appModel = AppModel()
    @State private var aiService = AIService()

    var body: some Scene {
        WindowGroup {
            SpeechDemoView()
                .environment(appModel)
                .environment(aiService)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environment(aiService)
                .onAppear { appModel.immersiveSpaceState = .open }
                .onDisappear { appModel.immersiveSpaceState = .closed }
        }
    }
}
