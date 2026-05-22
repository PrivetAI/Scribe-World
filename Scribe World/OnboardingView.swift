import SwiftUI

// 4-step onboarding: select cell -> type -> switch direction -> check.
struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var step = 0

    private let steps: [(title: String, body: String)] = [
        ("Select a Cell", "Tap any white square to begin. The whole entry it belongs to lights up, and the clue appears in the bar above the grid."),
        ("Type Letters", "Use the on-screen A–Z keyboard to fill the active entry. Each letter auto-advances to the next empty square in the word."),
        ("Switch Direction", "Tap the selected square again to flip between the Across and Down clue that cross at that cell. Use the arrows to jump clue to clue."),
        ("Check & Reveal", "Stuck? The Check tool flags wrong letters in red. Reveal fills a letter or word — but a clean solve (no reveals) earns a star.")
    ]

    var body: some View {
        ZStack {
            Scribe.ink.opacity(0.6).edgesIgnoringSafeArea(.all)
            ScribeCard {
                VStack(spacing: 18) {
                    stepIllustration
                        .frame(height: 120)

                    Text(steps[step].title)
                        .font(Scribe.titleBold(22))
                        .foregroundColor(Scribe.ink)
                    Text(steps[step].body)
                        .font(Scribe.body(15))
                        .foregroundColor(Scribe.inkSoft)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(minHeight: 86)

                    HStack(spacing: 7) {
                        ForEach(0..<steps.count, id: \.self) { i in
                            Circle()
                                .fill(i == step ? Scribe.brass : Scribe.parchmentDeep)
                                .frame(width: 8, height: 8)
                        }
                    }

                    HStack(spacing: 12) {
                        if step > 0 {
                            Button(action: { withAnimation { step -= 1 } }) {
                                Text("Back")
                                    .font(Scribe.title(16)).foregroundColor(Scribe.brassDeep)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(RoundedRectangle(cornerRadius: 11).strokeBorder(Scribe.brass.opacity(0.5), lineWidth: 1))
                            }
                        }
                        Button(action: {
                            if step < steps.count - 1 { withAnimation { step += 1 } }
                            else { onFinish() }
                        }) {
                            Text(step < steps.count - 1 ? "Next" : "Start Solving")
                                .font(Scribe.title(16)).foregroundColor(Scribe.panel)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 11).fill(Scribe.brass))
                        }
                    }

                    Button(action: onFinish) {
                        Text("Skip").font(Scribe.body(13)).foregroundColor(Scribe.inkSoft)
                    }
                }
                .padding(6)
            }
            .frame(maxWidth: 340)
            .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    private var stepIllustration: some View {
        // a tiny demonstrative mini-grid varies per step
        let active: Set<Int> = [3, 4, 5]
        let selected = step == 0 ? 4 : (step == 2 ? 4 : 5)
        let letters: [Int: String] = step >= 1 ? [3: "C", 4: "A", 5: step >= 1 ? "T" : ""] : [:]
        let wrong: Set<Int> = step == 3 ? [5] : []
        VStack(spacing: 0) {
            HStack(spacing: 0) { miniCell(0, active, selected, letters, wrong); miniCell(1, active, selected, letters, wrong); miniCell(2, active, selected, letters, wrong, block: true) }
            HStack(spacing: 0) { miniCell(3, active, selected, letters, wrong); miniCell(4, active, selected, letters, wrong); miniCell(5, active, selected, letters, wrong) }
            HStack(spacing: 0) { miniCell(6, active, selected, letters, wrong, block: true); miniCell(7, active, selected, letters, wrong); miniCell(8, active, selected, letters, wrong) }
        }
        .overlay(Rectangle().strokeBorder(Scribe.ink, lineWidth: 2))
    }

    private func miniCell(_ i: Int, _ active: Set<Int>, _ selected: Int, _ letters: [Int: String], _ wrong: Set<Int>, block: Bool = false) -> some View {
        ZStack {
            if block {
                Rectangle().fill(Scribe.cellBlock)
            } else {
                Rectangle().fill(i == selected ? Scribe.cellSelected : (active.contains(i) ? Scribe.cellActive.opacity(0.6) : Scribe.cellFill))
                Rectangle().stroke(Scribe.ink.opacity(0.5), lineWidth: 0.6)
                if let l = letters[i], !l.isEmpty {
                    Text(l).font(Scribe.title(20)).foregroundColor(wrong.contains(i) ? Scribe.wrong : Scribe.ink)
                }
            }
        }
        .frame(width: 38, height: 38)
    }
}
