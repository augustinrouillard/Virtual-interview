import SwiftUI

struct WelcomeView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(AIService.self) private var aiService
    
    // Actions pour gérer l'espace immersif
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var immersiveSpaceIsShown = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // --- Header Logo ---
            headerSection
            
            // --- Card Principale ---
            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Text("Simulation d'entretien")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Entraînez-vous dans un environnement\nsécurisé et immersif")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // BOUTON LANCER (2D + 3D)
                Button(action: {
                    toggleSimulation()
                }) {
                    Text(immersiveSpaceIsShown ? "Quitter l'immersion" : "Lancer la simulation")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(buttonGradient)
                        .cornerRadius(28)
                        .shadow(color: Color(hex: "7C4DFF").opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                
                // Petit indicateur d'état
                if immersiveSpaceIsShown {
                    Text("Espace Immersif Activé")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding(40)
            .frame(maxWidth: 450)
            .background(cardBackground)
            
            Spacer()
        }
    }

    // MARK: - Logique de lancement
    private func toggleSimulation() {
        Task {
            if immersiveSpaceIsShown {
                // Fermer l'espace 3D
                await dismissImmersiveSpace()
                immersiveSpaceIsShown = false
                appModel.interviewState = .welcome
            } else {
                // 1. Ouvrir l'espace 3D (ImmersiveView)
                let result = await openImmersiveSpace(id: appModel.immersiveSpaceID)
                
                switch result {
                case .opened:
                    immersiveSpaceIsShown = true
                    // 2. Lancer la logique métier
                    aiService.resetInterview()
                    appModel.interviewState = .recording
                case .error, .userCancelled:
                    print("Erreur lors de l'ouverture de l'espace")
                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: - Composants Visuels
    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(Color(hex: "7C4DFF")).frame(width: 80, height: 80)
                Image(systemName: "visionpro").font(.system(size: 36)).foregroundColor(.white)
            }
            Text("BPCE GROUP").font(.system(size: 14, weight: .semibold)).tracking(2)
        }
        .padding(.bottom, 40)
    }

    private var buttonGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "7C4DFF"), Color(hex: "6A3DE8")], startPoint: .leading, endPoint: .trailing)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 30).fill(.white).shadow(color: .black.opacity(0.08), radius: 30)
    }
}
