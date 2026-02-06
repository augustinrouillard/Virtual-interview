import SwiftUI
import RealityKit
import RealityKitContent
 
struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            
            // --- 1. LE CIEL (SKYBOX) ---
            let skyboxEntity = Entity()
            let skyboxMesh = MeshResource.generateSphere(radius: 4)
            
            do {
                let texture = try await TextureResource(named: "room_test")
                var material = UnlitMaterial()
                material.color = .init(texture: .init(texture))
                
                // Fait pivoter l'image de 90 degrés (1.57 radians) sur l'axe Y
                skyboxEntity.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 0.4, 0])
                skyboxEntity.components.set(ModelComponent(mesh: skyboxMesh, materials: [material]))
                
                // IMPORTANT : Échelle X à -1 pour voir l'image de l'intérieur
                skyboxEntity.scale = .init(x: -1, y: 1, z: 1)
                skyboxEntity.position = [0, 1.75, -2]
                
                content.add(skyboxEntity)
            } catch {
                print("❌ Erreur chargement texture ciel : \(error)")
            }
 
            // --- 2. L'ÉCLAIRAGE (IBL) ---
            let iblEntity = Entity()
            if let skyResource = try? await EnvironmentResource(named: "room_test") {
                var iblComponent = ImageBasedLightComponent(source: .single(skyResource))
                iblComponent.intensityExponent = 1.0 // Ajuste la luminosité ici
                iblEntity.components.set(iblComponent)
                content.add(iblEntity)
            }
 
            // --- 3. LA TABLE ---
            if let table = try? await Entity(named: "uploads_files_3468480_GLASS_MONEY_TABLE_01 1") {
                
                // Position : 1.5m devant et posée au sol (ajuster le Y selon le pivot du modèle)
                table.position = [0, 0.2, -0.7]
                
                // Échelle : Teste 0.001 si 0.01 est trop grand
                // On passe de 0.0001 à 0.00025 (2,5 fois plus grande)
                table.scale = [0.00035, 0.00025, 0.00025]
                
                // Lier la table à la lumière IBL pour les reflets sur le verre
                table.components.set(ImageBasedLightReceiverComponent(imageBasedLight: iblEntity))
                
                content.add(table)
                print("✅ Table affichée avec éclairage IBL")
            } else {
                print("❌ Erreur : Fichier 3D introuvable dans le bundle")
            }
            if let avatar = try? await Entity(named: "AVATAR-FULLBODYFRAG") {
                
                // Position : 1.5m devant et posée au sol (ajuster le Y selon le pivot du modèle)
                avatar.position = [0, -0.2, -1.5]
                
                // Échelle : Teste 0.001 si 0.01 est trop grand
                // On passe de 0.0001 à 0.00025 (2,5 fois plus grande)
                avatar.scale = [0.0075, 0.0075, 0.0075]
                
                // Lier la table à la lumière IBL pour les reflets sur le verre
                avatar.components.set(ImageBasedLightReceiverComponent(imageBasedLight: iblEntity))
                
                content.add(avatar)
                print("✅ Table affichée avec éclairage IBL")
            } else {
                print("❌ Erreur : Fichier 3D introuvable dans le bundle")
            }
            
        }
    }
}
