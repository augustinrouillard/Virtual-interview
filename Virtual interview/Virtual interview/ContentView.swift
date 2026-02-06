import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 30) {
            Text("Virtual Interview")
                .font(.largeTitle)
                .bold()

            if appModel.immersiveSpaceState == .closed {
                Button("Afficher l'environnement") {
                    Task {
                        appModel.immersiveSpaceState = .inTransition
                        await openImmersiveSpace(id: appModel.immersiveSpaceID)
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                // Syntaxe explicite pour ButtonRole
                Button(role: ButtonRole.destructive) {
                    Task {
                        appModel.immersiveSpaceState = .inTransition
                        await dismissImmersiveSpace()
                    }
                } label: {
                    Text("Quitter l'immersion")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
