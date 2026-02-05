import SwiftUI

/// Une forme personnalisée représentant un triangle équilatéral.
/// Cette forme peut être utilisée dans SwiftUI comme n'importe quelle autre Shape.
/// Le triangle est dessiné à partir d'un point de départ en bas à gauche,
/// en traçant une ligne vers le sommet, puis vers le coin en bas à droite,
/// et enfin en fermant le chemin.
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Point en bas à gauche
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        // Point en haut au centre
        let topCenter = CGPoint(x: rect.midX, y: rect.minY)
        // Point en bas à droite
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: bottomLeft)
        path.addLine(to: topCenter)
        path.addLine(to: bottomRight)
        path.closeSubpath()
        
        return path
    }
}

/// Vue SwiftUI immersive affichant plusieurs triangles.
/// Chaque triangle a une taille, position et couleur différentes,
/// créant un effet visuel intéressant et dynamique.
/// Cette vue peut être utilisée comme contenu immersif dans une application SwiftUI.
struct TrianglesImmersiveView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fond très visible pour repérer facilement la surface immersive
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Cadre/bordure pour matérialiser clairement les limites de la surface 2D
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.white.opacity(0.9), lineWidth: 6)
                    .padding(24)

                // Titre explicite pour confirmer l'affichage de la vue immersive
                VStack(spacing: 12) {
                    Text("Espace immersif: Triangles")
                        .font(.system(size: 48, weight: .heavy))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)

                    Text("Si vous voyez ce titre, la vue immersive est bien affichée.")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.top, 40)
                .frame(maxHeight: .infinity, alignment: .top)

                // Plusieurs triangles placés avec différentes tailles, positions et couleurs
                // Tailles augmentées pour être très visibles
                Triangle()
                    .fill(Color.red.opacity(0.9))
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                    .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.35)

                Triangle()
                    .fill(Color.blue.opacity(0.85))
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.3)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.45)
                    .rotationEffect(.degrees(18))

                Triangle()
                    .fill(Color.green.opacity(0.85))
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.72)
                    .rotationEffect(.degrees(-12))

                Triangle()
                    .stroke(Color.white.opacity(0.9), lineWidth: 5)
                    .frame(width: geometry.size.width * 0.28, height: geometry.size.width * 0.28)
                    .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.85)

                Triangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.95), Color.pink.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                    .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.78)
                    .rotationEffect(.degrees(42))
            }
            .onAppear {
                // Journalise l'apparition de la vue immersive pour diagnostic
                print("TrianglesImmersiveView appeared (immersive content visible)")
            }
            .onDisappear {
                // Journalise la disparition de la vue immersive pour diagnostic
                print("TrianglesImmersiveView disappeared (immersive content hidden)")
            }
        }
    }
}

#Preview {
    TrianglesImmersiveView()
}
