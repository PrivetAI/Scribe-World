import SwiftUI

// Custom on-screen A–Z keyboard built from Buttons (no system keyboard).
// Letters rendered as Text. Includes backspace.
struct ScribeKeyboard: View {
    let onLetter: (Character) -> Void
    let onBackspace: () -> Void

    private let rows: [[Character]] = [
        Array("QWERTYUIOP"),
        Array("ASDFGHJKL"),
        Array("ZXCVBNM")
    ]

    var body: some View {
        GeometryReader { geo in
            let totalW = geo.size.width
            let spacing: CGFloat = 5
            // base key width from the 10-key top row
            let keyW = (totalW - spacing * 11) / 10
            let keyH = min(max(keyW * 1.28, 38), 56)
            VStack(spacing: spacing) {
                ForEach(0..<rows.count, id: \.self) { ri in
                    HStack(spacing: spacing) {
                        if ri == 1 { Spacer(minLength: keyW * 0.5) }
                        ForEach(rows[ri], id: \.self) { ch in
                            KeyButton(label: String(ch), width: keyW, height: keyH) {
                                onLetter(ch)
                            }
                        }
                        if ri == 1 { Spacer(minLength: keyW * 0.5) }
                        if ri == 2 {
                            Button(action: onBackspace) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .fill(Scribe.parchmentDeep)
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .strokeBorder(Scribe.brass.opacity(0.4), lineWidth: 1)
                                    BackspaceIcon(color: Scribe.ink)
                                        .frame(width: keyH * 0.5, height: keyH * 0.5)
                                }
                                .frame(width: keyW * 1.6, height: keyH)
                            }
                            .buttonStyle(KeyPressStyle())
                        }
                    }
                }
            }
            .frame(width: totalW, alignment: .center)
        }
        .frame(height: 178)
    }
}

private struct KeyButton: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Scribe.panel)
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(Scribe.brass.opacity(0.4), lineWidth: 1)
                Text(label)
                    .font(Scribe.title(min(height * 0.46, 22)))
                    .foregroundColor(Scribe.ink)
            }
            .frame(width: width, height: height)
            .shadow(color: Scribe.ink.opacity(0.08), radius: 1.5, y: 1)
        }
        .buttonStyle(KeyPressStyle())
    }
}

private struct KeyPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}
