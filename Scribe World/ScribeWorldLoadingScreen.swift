import SwiftUI

// Splash screen shown while the launch check runs.
struct ScribeWorldLoadingScreen: View {
    @State private var scribeWorldGlow = false

    var body: some View {
        ZStack {
            ParchmentBackground()
            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(Scribe.panel)
                        .frame(width: 132, height: 132)
                        .overlay(Circle().strokeBorder(Scribe.brass.opacity(0.4), lineWidth: 2))
                        .shadow(color: Scribe.ink.opacity(0.12), radius: 8, y: 4)
                    ScribeIcon(color: Scribe.brassDeep)
                        .frame(width: 72, height: 72)
                        .opacity(scribeWorldGlow ? 1.0 : 0.55)
                }
                Text("Scribe")
                    .font(Scribe.titleBold(28))
                    .foregroundColor(Scribe.ink)
                Text("World")
                    .font(Scribe.title(20))
                    .foregroundColor(Scribe.brassDeep)
                    .tracking(3)

                // simple animated dots line
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Scribe.brass.opacity(scribeWorldGlow ? 0.9 : 0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.7).repeatForever().delay(Double(i) * 0.2),
                                       value: scribeWorldGlow)
                    }
                }
                .padding(.top, 6)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                scribeWorldGlow = true
            }
        }
    }
}
