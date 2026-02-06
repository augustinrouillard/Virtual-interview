import SwiftUI

struct ToggleImmersiveSpaceButton: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        Button {
            Task {
                if appModel.immersiveSpaceState == .open {
                    await dismissImmersiveSpace()
                } else {
                    await openImmersiveSpace(id: appModel.immersiveSpaceID)
                }
            }
        } label: {
            Text(appModel.immersiveSpaceState == .open ? "Quitter 3D" : "Voir en 3D")
        }
    }
}
