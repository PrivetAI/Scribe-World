import UIKit

// Lightweight haptics gated by settings.
enum Haptics {
    static func tap(_ store: ScribeStore) {
        guard store.settings.haptics else { return }
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }
    static func success(_ store: ScribeStore) {
        guard store.settings.haptics else { return }
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
    }
    static func soft(_ store: ScribeStore) {
        guard store.settings.haptics else { return }
        let gen = UIImpactFeedbackGenerator(style: .soft)
        gen.impactOccurred()
    }
}
