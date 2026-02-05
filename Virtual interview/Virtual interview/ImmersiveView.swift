//
//  ImmersiveView.swift
//  Virtual interview
//
//  Remplacé pour afficher des triangles 3D avec RealityKit dans l'espace immersif.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            // Racine de la scène RealityKit
            let root = Entity()
            content.add(root)

            // Lumière directionnelle pour éclairer la scène et rendre les triangles visibles
            let lightEntity = Entity()
            var light = DirectionalLightComponent()
            light.intensity = 8000 // intensité plus forte pour bien voir
            lightEntity.components.set(light)
            // Incline la lumière vers le bas
            lightEntity.orientation = simd_quatf(angle: -.pi/4, axis: [1, 0, 0])
            root.addChild(lightEntity)

            // Skybox simple: grande sphère non éclairée, inversée pour être vue de l'intérieur
            let skyMesh = MeshResource.generateSphere(radius: 50)
            let skyMaterial = UnlitMaterial(color: .init(red: 0.05, green: 0.06, blue: 0.09, alpha: 1))
            let sky = ModelEntity(mesh: skyMesh, materials: [skyMaterial])
            sky.scale = [-1, 1, 1] // inversion X pour retourner les normales
            root.addChild(sky)

            // Fonction utilitaire: construit un prisme triangulaire fin (extrusion d'un triangle)
            @MainActor
            func makeTrianglePrism(p0: SIMD3<Float>, p1: SIMD3<Float>, p2: SIMD3<Float>, depth: Float, color: UIColor) -> ModelEntity {
                let frontZ: Float = 0
                let backZ: Float = -depth

                // Sommets (face avant et arrière)
                let v0 = SIMD3<Float>(p0.x, p0.y, frontZ)
                let v1 = SIMD3<Float>(p1.x, p1.y, frontZ)
                let v2 = SIMD3<Float>(p2.x, p2.y, frontZ)
                let v3 = SIMD3<Float>(p0.x, p0.y, backZ)
                let v4 = SIMD3<Float>(p1.x, p1.y, backZ)
                let v5 = SIMD3<Float>(p2.x, p2.y, backZ)

                // Indices pour triangles (faces avant, arrière, et côtés)
                let front: [UInt32] = [0,1,2]
                let back: [UInt32]  = [5,4,3] // inversé pour la face arrière
                let sideA: [UInt32] = [0,3,1, 1,3,4]
                let sideB: [UInt32] = [1,4,2, 2,4,5]
                let sideC: [UInt32] = [2,5,0, 0,5,3]

                var desc = MeshDescriptor()
                desc.positions = .init([v0,v1,v2,v3,v4,v5])
                desc.primitives = .triangles(front + back + sideA + sideB + sideC)

                let mesh = try! MeshResource.generate(from: [desc])

                var pbr = PhysicallyBasedMaterial()
                pbr.baseColor = .init(tint: color)
                pbr.metallic = 0.1
                pbr.roughness = 0.35

                return ModelEntity(mesh: mesh, materials: [pbr])
            }

            // Crée et positionne plusieurs triangles 3D devant l'utilisateur
            let t1 = makeTrianglePrism(
                p0: [-0.4,  0.2, 0], p1: [-0.1, 0.6, 0], p2: [0.2, 0.2, 0],
                depth: 0.02, color: .systemRed
            )
            t1.position = [-0.6, 1.4, -2.0] // x, y, z (en mètres)
            root.addChild(t1)

            let t2 = makeTrianglePrism(
                p0: [0.0, 0.1, 0], p1: [0.5, 0.5, 0], p2: [0.6, 0.0, 0],
                depth: 0.02, color: .systemBlue
            )
            t2.position = [0.2, 1.2, -2.2]
            t2.orientation = simd_quatf(angle: .pi/14, axis: [0,1,0])
            root.addChild(t2)

            let t3 = makeTrianglePrism(
                p0: [-0.2, -0.2, 0], p1: [0.2, -0.2, 0], p2: [0.0, 0.3, 0],
                depth: 0.03, color: .systemGreen
            )
            t3.position = [-0.1, 0.8, -1.8]
            t3.orientation = simd_quatf(angle: -.pi/18, axis: [0,1,0])
            root.addChild(t3)

            print("Immersive RealityView loaded: 3D triangles added")
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}

