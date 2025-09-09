//
//  AudioPlayerService.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import AVFoundation
import Combine

// MARK: - Voice Configuration
public enum SpeechAccent: String, CaseIterable, Identifiable, Codable {
    case american = "en-US"
    case british = "en-GB"
    case australian = "en-AU"

    public var id: String { rawValue }

    public var localizedName: String {
        switch self {
        case .american: return "American"
        case .british: return "British"
        case .australian: return "Australian"
        }
    }

    public var countryFlag: String {
        switch self {
        case .american: return "🇺🇸"
        case .british: return "🇬🇧"
        case .australian: return "🇦🇺"
        }
    }
    
    public var shortName: String {
        switch self {
        case .american: return "American"
        case .british: return "British"
        case .australian: return "Australian"
        }
    }
}

// MARK: - Audio Configuration
private struct AudioConfiguration {
    static let defaultSpeechRate: Float = 0.4
    static let successSoundID: SystemSoundID = 1016
    static let voicePreferenceKey = "selectedVoice"
    static let speechRateKey = "speechRate"
}

// MARK: - Speech Engine Manager
@MainActor
public final class SpeechEngineManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published public private(set) var isCurrentlySpeaking = false
    @Published public private(set) var selectedAccent: SpeechAccent
    @Published public private(set) var speechRate: Float = AudioConfiguration.defaultSpeechRate
    
    // MARK: - Private Properties
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public override init() {
        // Load saved preferences or use defaults
        let savedAccentRaw = userDefaults.string(forKey: AudioConfiguration.voicePreferenceKey) ?? SpeechAccent.american.rawValue
        self.selectedAccent = SpeechAccent(rawValue: savedAccentRaw) ?? .american
        self.speechRate = userDefaults.float(forKey: AudioConfiguration.speechRateKey) != 0 ? 
                         userDefaults.float(forKey: AudioConfiguration.speechRateKey) : 
                         AudioConfiguration.defaultSpeechRate
        
        super.init()
        configureAudioSession()
        setupSpeechSynthesizer()
    }
    
    // MARK: - Public Interface
    public func speakText(_ text: String) {
        guard !text.isEmpty else { return }
        
        let speechUtterance = createSpeechUtterance(for: text)
        speechSynthesizer.speak(speechUtterance)
    }
    
    public func updateAccent(_ newAccent: SpeechAccent) {
        selectedAccent = newAccent
        persistAccentPreference()
    }
    
    public func updateSpeechRate(_ newRate: Float) {
        speechRate = max(0.1, min(1.0, newRate)) // Clamp between 0.1 and 1.0
        persistSpeechRatePreference()
    }
    
    public func stopCurrentSpeech() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    public func playNotificationSound() {
        AudioServicesPlaySystemSound(AudioConfiguration.successSoundID)
    }
    
    // MARK: - Private Configuration
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("❌ Audio session configuration failed: \(error.localizedDescription)")
        }
    }
    
    private func setupSpeechSynthesizer() {
        speechSynthesizer.delegate = self
    }
    
    private func createSpeechUtterance(for text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: selectedAccent.rawValue)
        utterance.rate = speechRate
        utterance.volume = 1.0
        return utterance
    }
    
    // MARK: - Persistence
    private func persistAccentPreference() {
        userDefaults.set(selectedAccent.rawValue, forKey: AudioConfiguration.voicePreferenceKey)
    }
    
    private func persistSpeechRatePreference() {
        userDefaults.set(speechRate, forKey: AudioConfiguration.speechRateKey)
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension SpeechEngineManager: AVSpeechSynthesizerDelegate {
    
    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isCurrentlySpeaking = true
        }
    }
    
    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isCurrentlySpeaking = false
        }
    }
    
    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isCurrentlySpeaking = false
        }
    }
}

// MARK: - Backward Compatibility
public typealias AudioPlayerService = SpeechEngineManager
