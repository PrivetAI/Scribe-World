import SwiftUI

struct CompletionOverlay: View {
    let time: Int
    let clean: Bool
    let bestTime: Int
    let onContinue: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            Quill.ink.opacity(0.6).edgesIgnoringSafeArea(.all)
            QuillCard {
                VStack(spacing: 16) {
                    ZStack {
                        Circle().fill(Quill.brass.opacity(0.18)).frame(width: 92, height: 92)
                        if clean {
                            StarIcon(filled: true, color: Quill.star)
                                .frame(width: 60, height: 60)
                                .scaleEffect(appear ? 1 : 0.4)
                        } else {
                            CheckIcon(color: Quill.correctTint)
                                .frame(width: 54, height: 54)
                                .scaleEffect(appear ? 1 : 0.4)
                        }
                    }
                    Text("Puzzle Solved")
                        .font(Quill.titleBold(24))
                        .foregroundColor(Quill.ink)

                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            ClockIcon(color: Quill.inkSoft).frame(width: 16, height: 16)
                            Text(timeString(time))
                                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                                .foregroundColor(Quill.ink)
                        }
                        if clean {
                            HStack(spacing: 6) {
                                StarIcon(filled: true, color: Quill.star).frame(width: 14, height: 14)
                                Text("Clean solve — no reveals")
                                    .font(Quill.body(13)).foregroundColor(Quill.brassDeep)
                            }
                        } else {
                            Text("Solved with help")
                                .font(Quill.body(13)).foregroundColor(Quill.inkSoft)
                        }
                        if bestTime > 0 {
                            Text("Best: \(timeString(bestTime))")
                                .font(Quill.body(12)).foregroundColor(Quill.inkSoft)
                        }
                    }

                    Button(action: onContinue) {
                        Text("Continue")
                            .font(Quill.title(18)).foregroundColor(Quill.panel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Quill.brass))
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
