import SwiftUI

struct CompletionOverlay: View {
    let time: Int
    let clean: Bool
    let bestTime: Int
    let onContinue: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            Scribe.ink.opacity(0.6).edgesIgnoringSafeArea(.all)
            ScribeCard {
                VStack(spacing: 16) {
                    ZStack {
                        Circle().fill(Scribe.brass.opacity(0.18)).frame(width: 92, height: 92)
                        if clean {
                            StarIcon(filled: true, color: Scribe.star)
                                .frame(width: 60, height: 60)
                                .scaleEffect(appear ? 1 : 0.4)
                        } else {
                            CheckIcon(color: Scribe.correctTint)
                                .frame(width: 54, height: 54)
                                .scaleEffect(appear ? 1 : 0.4)
                        }
                    }
                    Text("Puzzle Solved")
                        .font(Scribe.titleBold(24))
                        .foregroundColor(Scribe.ink)

                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            ClockIcon(color: Scribe.inkSoft).frame(width: 16, height: 16)
                            Text(timeString(time))
                                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                                .foregroundColor(Scribe.ink)
                        }
                        if clean {
                            HStack(spacing: 6) {
                                StarIcon(filled: true, color: Scribe.star).frame(width: 14, height: 14)
                                Text("Clean solve — no reveals")
                                    .font(Scribe.body(13)).foregroundColor(Scribe.brassDeep)
                            }
                        } else {
                            Text("Solved with help")
                                .font(Scribe.body(13)).foregroundColor(Scribe.inkSoft)
                        }
                        if bestTime > 0 {
                            Text("Best: \(timeString(bestTime))")
                                .font(Scribe.body(12)).foregroundColor(Scribe.inkSoft)
                        }
                    }

                    Button(action: onContinue) {
                        Text("Continue")
                            .font(Scribe.title(18)).foregroundColor(Scribe.panel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Scribe.brass))
                    }
                    .padding(.top, 4)
                }
                .padding(6)
            }
            .frame(maxWidth: 320)
            .scaleEffect(appear ? 1 : 0.85)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { appear = true }
        }
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}
