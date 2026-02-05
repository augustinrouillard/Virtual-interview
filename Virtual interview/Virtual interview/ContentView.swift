//
//  ContentView.swift
//  Virtual interview
//
//  Created by bpce-si on 05/02/2026.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hello, world!")

            // Indicateur d'état pour comprendre le cycle d'ouverture/fermeture de l'espace immersif.
            Text("État espace immersif: \(String(describing: appModel.immersiveSpaceState))")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)

            ToggleImmersiveSpaceButton()

            Text("Appuyez sur le bouton pour ouvrir/fermer l'espace immersif et afficher les triangles.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            // Diagnostic: au lancement, on tente d'ouvrir l'espace immersif automatiquement
            // pour vérifier que la configuration fonctionne. Cela vous permet de voir
            // immédiatement les triangles sans appuyer sur le bouton. Vous pouvez
            // commenter/supprimer ce bloc une fois vos tests terminés.
            Task { @MainActor in
                if appModel.immersiveSpaceState == .closed {
                    let result = await openImmersiveSpace(id: appModel.immersiveSpaceID)
                    // Journalise le résultat pour le diagnostic.
                    print("openImmersiveSpace result:", String(describing: result))
                }
            }
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
