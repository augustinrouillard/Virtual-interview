import SwiftUI
import AVFoundation
import Observation

@MainActor
@Observable
class AppModel {
    // États de l'espace immersif
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState { case closed, inTransition, open }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    // États de l'entretien
    enum InterviewState { case welcome, recording, finished }
    var interviewState: InterviewState = .welcome
    
    // Données de session
    var recordedAudioURL: URL?
    var recordingDuration: TimeInterval = 0
    
    func resetInterview() {
        recordingDuration = 0
        recordedAudioURL = nil
        interviewState = .welcome
    }
    
    func finishInterview(url: URL?) {
        self.recordedAudioURL = url
        self.interviewState = .finished
    }
}
