//
//  Virtual_interviewApp.swift
//  Virtual interview
//
//  Created by bpce-si on 05/02/2026.
//

import SwiftUI

@main
struct Virtual_interviewApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    // Marque l'état comme "ouvert" lorsque l'espace immersif apparaît.
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    // Marque l'état comme "fermé" lorsque l'espace immersif disparaît.
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
