import SwiftUI

// Splash screen shown while the launch check runs.
struct CrosswordQuillLoadingScreen: View {
    @State private var crosswordQuillGlow = false

    var body: some View {
        ZStack {
            ParchmentBackground()
            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(Quill.panel)
                        .frame(width: 132, height: 132)
                        .overlay(Circle().strokeBorder(Quill.brass.opacity(0.4), lineWidth: 2))
                        .shadow(color: Quill.ink.opacity(0.12), radius: 8, y: 4)
                    QuillIcon(color: Quill.brassDeep)
                        .frame(width: 72, height: 72)
                        .opacity(crosswordQuillGlow ? 1.0 : 0.55)
                }
                Text("Crossword Quill")
                    .font(Quill.titleBold(28))
                    .foregroundColor(Quill.ink)
                Text("Daily")
                    .font(Quill.title(20))
                    .foregroundColor(Quill.brassDeep)
                    .tracking(3)

                // simple animated dots line
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Quill.brass.opacity(crosswordQuillGlow ? 0.9 : 0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.7).repeatForever().delay(Double(i) * 0.2),
                                       value: crosswordQuillGlow)
                    }
                }
                .padding(.top, 6)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                crosswordQuillGlow = true
            }
        }
    }
}
