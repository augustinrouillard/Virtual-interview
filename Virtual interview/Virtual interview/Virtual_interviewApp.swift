import SwiftUI

@main
struct Virtual_interviewApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        // Dans Virtual_interviewApp.swift
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear { appModel.immersiveSpaceState = .open }
                .onDisappear { appModel.immersiveSpaceState = .closed }
        }
        // CHANGEZ .mixed par .full ICI :
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
