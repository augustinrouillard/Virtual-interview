import Foundation
import AVFoundation

class AIService {
    private let synthesizer = AVSpeechSynthesizer()
    
    // Liste des questions pour simuler un entretien
    private var questions = [
        "Enchanté ! Pour commencer, pouvez-vous vous présenter brièvement ?",
        "C'est très intéressant. Pourquoi avez-vous postulé pour ce poste en particulier ?",
        "Quelles sont, selon vous, vos trois plus grandes qualités pour ce rôle ?",
        "Merci pour ces précisions. Avez-vous une question à me poser sur l'entreprise ?",
        "L'entretien est terminé. Nous reviendrons vers vous très prochainement. Bonne journée !"
    ]
    
    private var currentQuestionIndex = 0
    
    func sayResponse(to userText: String) {
        let text = userText.lowercased()
        var aiReply = ""
        
        // 1. LOGIQUE D'ANALYSE (On simule une intelligence)
        if text.isEmpty {
            aiReply = "Je n'ai pas bien entendu. Pouvez-vous répéter ?"
        } else {
            // On prépare une petite phrase de transition selon ce que l'utilisateur a dit
            let transition = generateTransition(for: text)
            
            // On récupère la question suivante dans la liste
            if currentQuestionIndex < questions.count {
                aiReply = transition + " " + questions[currentQuestionIndex]
                currentQuestionIndex += 1
            } else {
                aiReply = "L'entretien est déjà terminé, merci encore !"
            }
        }
        
        // 2. SYNTHÈSE VOCALE (Le Vision Pro parle)
        let utterance = AVSpeechUtterance(string: aiReply)
        
        // Configuration de la voix
        if let frenchVoice = AVSpeechSynthesisVoice(language: "fr-FR") {
            utterance.voice = frenchVoice
        }
        
        utterance.rate = 0.5 // Vitesse de parole (0.5 est naturel)
        utterance.pitchMultiplier = 1.0 // Hauteur de la voix
        utterance.volume = 1.0
        
        // On arrête toute parole en cours avant d'en lancer une nouvelle
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    // Fonction privée pour simuler une compréhension des mots-clés
    private func generateTransition(for text: String) -> String {
        if text.contains("bonjour") || text.contains("salut") {
            return "Bonjour !"
        } else if text.contains("merci") {
            return "Je vous en prie."
        } else if text.contains("développement") || text.contains("code") || text.contains("swift") {
            return "C'est un domaine passionnant."
        } else {
            return "D'accord, je comprends."
        }
    }
    
    // Pour recommencer l'entretien à zéro
    func resetInterview() {
        currentQuestionIndex = 0
    }
}
