import Foundation
import AVFoundation
import SwiftUI
import Observation

// ✅ Structure pour le bilan
struct RapportEntretien {
    var scoreRelationnel: Int = 0
    var scoreTechnique: Int = 0
    var pointsPositifs: [String] = []
    var pointsAmelioration: [String] = []
    var scoreTotal: Int { scoreRelationnel + scoreTechnique }
}

@Observable
class AIService: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    
    var isSpeaking: Bool = false
    var rapportFinal: RapportEntretien? = nil
    var simulationTerminee: Bool = false
    
    private var scoreRelationnel = 0
    private var scoreTechnique = 0
    private var currentStep = 0
    private var feedbacks: [String] = []
    private var pointsManquants: [String] = []

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func sayResponse(to userText: String) {
        let text = userText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return }

        var aiReply = ""
        switch currentStep {
        case 0: aiReply = handleAccueil(text)
        case 1: aiReply = handleAnalyseSituation(text)
        case 2: aiReply = handleSeasonSituation(text    )
        case 3: aiReply = handleQuestionsCredits(text)
        case 4: aiReply = handleNegociationEndettement(text)
        case 5: aiReply = handleConclusionPret(text)
        default:
            genererRapportFinal()
            return
        }
        
        speak(aiReply)
    }

    private func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        utterance.rate = 0.5
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
        
        synthesizer.speak(utterance)
    }

    // MARK: - Etape 0 : Accueil
    private func handleAccueil(_ text: String) -> String {
        if text.contains("bonjour") || text.contains("bienvenue") {
            scoreRelationnel += 10
            feedbacks.append("Politesse : Accueil pro validé.")
            currentStep = 1
            return "Bonjour, je viens vous voir car j'aimerais contracter un prêt pour l'achat d'un bien immobilier. Que me conseillez-vous ?"
        } else {
            scoreRelationnel -= 5
            pointsManquants.append("Accueil : Manque de salutations.")
            return "Bonjour ? On commence directement comme ça ?"
        }
    }

    // MARK: - Etape 1 : Situation actuelle
    private func handleAnalyseSituation(_ text: String) -> String {
        let motsCles = ["situation", "faites", "métier", "revenus", "travail"]
        if motsCles.contains(where: text.contains) {
            scoreTechnique += 15
            feedbacks.append("Technique : Bonne découverte du profil client.")
            currentStep = 2
            return "Je suis gérant d'un camping au bord de la mer en Bretagne."
        } else {
            scoreTechnique -= 5
            pointsManquants.append("Découverte : Vous n'avez pas assez creusé ma situation pro.")
            return "Mais avant de me conseiller, vous ne voulez pas savoir ce que je fais dans la vie ?"
        }
    }
    
    
    // MARK: - Etape 2 : Situation actuelle
    private func handleSeasonSituation(_ text: String) -> String {
        let motsCles = ["essor", "saison", "saisonnier", "revenus", "moyenne"]
        if motsCles.contains(where: text.contains) {
            scoreTechnique += 15
            feedbacks.append("Technique : Bonne découverte du profil client.")
            currentStep = 3
            return "Je dégage environ 4 500 € net par mois en lissant sur l'année. J'ai trouvé un bien neuf à 250 000 € et j'ai 25 000 € d'apport. Je vis seul."
        } else {
            scoreTechnique -= 5
            pointsManquants.append("Découverte : Vous n'avez pas assez creusé ma situation pro.")
            return "Vous ne voulez pas savoir combien je gagne ?"
        }
    }
    
    
    // MARK: - Etape 3 : Crédits en cours
    private func handleQuestionsCredits(_ text: String) -> String {
        let motsCles = ["crédit", "emprunt", "cours", "dettes", "charges"]
        if motsCles.contains(where: text.contains) {
            scoreTechnique += 15
            feedbacks.append("Technique : Analyse des charges fixes effectuée.")
            currentStep = 4
            return "Oui, j'ai un crédit auto de 300 € par mois pendant encore 4 ans."
        } else {
            scoreTechnique -= 10
            pointsManquants.append("Risque : Oubli de vérifier les crédits en cours.")
            return "C'est un beau projet non ? On passe aux chiffres ?"
        }
    }

    // MARK: - Etape 3 : Taux d'endettement & Arguments
    private func handleNegociationEndettement(_ text: String) -> String {
        let motsCles = ["endettement", "coince", "bloque", "trop", "mensualité", "autorisé", "endettés"]
        if motsCles.contains(where: text.contains) {
            scoreTechnique += 20
            feedbacks.append("Analyse : Alerte pertinente sur le taux d'endettement.")
            currentStep = 5
            return "Je comprends, mais mon activité est en pleine croissance et le bien est neuf, donc j'aurai très peu de charges énergétiques. Qu'est-ce qu'on peut faire ?"
        } else {
            scoreTechnique -= 10
            pointsManquants.append("Analyse : Vous n'avez pas relevé le problème de mon crédit auto.")
            return "Est-ce que mon dossier passe selon vous ?"
        }
    }

    // MARK: - Etape 4 : Conclusion & Conditions
    private func handleConclusionPret(_ text: String) -> String {
        let conditions = ["solder", "voiture", "domiciliation", "assurance", "anticipation", "activité","appuyer","dossier"]
        let count = conditions.filter { text.contains($0) }.count
        if count >= 2 {
            scoreTechnique += 40
            scoreRelationnel += 10
            feedbacks.append("Commercial : Excellente négociation des contreparties (solder crédit + domiciliation).")
            currentStep = 5
            return "C'est entendu, je vais piocher dans mon épargne pour solder ce crédit voiture. Merci de votre confiance, on fait comme ça !"
        } else {
            scoreTechnique -= 10
            pointsManquants.append("Commercial : Conditions de validation trop vagues ou absentes.")
            return "Quelles sont les conditions exactes pour que ma banque accepte le dossier ?"
        }
    }

    // MARK: - Délégués et Rapport
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) { isSpeaking = true }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        currentStep == 6
        if currentStep ==  6 { genererRapportFinal() }
    }

    private func genererRapportFinal() {
        self.rapportFinal = RapportEntretien(
            scoreRelationnel: min(100, max(0, scoreRelationnel)),
            scoreTechnique: min(100, max(0, scoreTechnique)),
            pointsPositifs: feedbacks,
            pointsAmelioration: pointsManquants
        )
        self.simulationTerminee = true
    }

    func resetInterview() {
        currentStep = 0; scoreRelationnel = 0; scoreTechnique = 0
        feedbacks = []; pointsManquants = []; simulationTerminee = false; rapportFinal = nil
    }
}
