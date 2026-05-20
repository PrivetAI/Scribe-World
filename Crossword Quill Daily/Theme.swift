import SwiftUI

// Literary scriptorium palette — parchment / ink / brass / quill.
enum Quill {
    static let parchment = Color(red: 0.96, green: 0.93, blue: 0.85)   // page cream
    static let parchmentDeep = Color(red: 0.92, green: 0.88, blue: 0.78)
    static let panel = Color(red: 0.99, green: 0.97, blue: 0.91)        // lighter card
    static let ink = Color(red: 0.16, green: 0.14, blue: 0.12)          // charcoal ink
    static let inkSoft = Color(red: 0.34, green: 0.30, blue: 0.26)
    static let brass = Color(red: 0.72, green: 0.55, blue: 0.24)        // brass accent
    static let brassDeep = Color(red: 0.55, green: 0.40, blue: 0.16)
    static let quillBlue = Color(red: 0.27, green: 0.36, blue: 0.46)    // quill ink blue
    static let cellFill = Color(red: 0.995, green: 0.985, blue: 0.95)
    static let cellActive = Color(red: 0.86, green: 0.78, blue: 0.55)   // active entry tint
    static let cellSelected = Color(red: 0.76, green: 0.64, blue: 0.36) // selected cell
    static let cellBlock = Color(red: 0.18, green: 0.16, blue: 0.14)    // black square
    static let wrong = Color(red: 0.74, green: 0.24, blue: 0.20)        // error red
    static let correctTint = Color(red: 0.32, green: 0.50, blue: 0.34)  // reveal/correct green
    static let line = Color(red: 0.32, green: 0.27, blue: 0.20)
    static let star = Color(red: 0.83, green: 0.66, blue: 0.22)

    // Serif title font helper.
    static func title(_ size: CGFloat) -> Font {
        .custom("Georgia", size: size)
    }
    static func titleBold(_ size: CGFloat) -> Font {
        .custom("Georgia-Bold", size: size)
    }
    static func body(_ size: CGFloat) -> Font {
        .custom("Georgia", size: size)
    }
}

// A subtle parchment background with a soft vignette and ruled feel.
struct ParchmentBackground: View {
    var body: some View {
        ZStack {
            Quill.parchment
            LinearGradient(
                colors: [Quill.panel.opacity(0.6), Quill.parchmentDeep.opacity(0.5)],
                startPoint: .top, endPoint: .bottom
            )
            RadialGradient(
                colors: [Color.white.opacity(0.18), Color.clear],
                center: .top, startRadius: 20, endRadius: 520
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Reusable card surface.
struct QuillCard<Content: View>: View {
    var padding: CGFloat = 16
    let content: Content
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Quill.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Quill.brass.opacity(0.35), lineWidth: 1.2)
            )
            .shadow(color: Quill.ink.opacity(0.10), radius: 6, x: 0, y: 3)
    }
}
