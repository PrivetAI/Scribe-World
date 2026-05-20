import SwiftUI

struct HowToPlayView: View {
    private let sections: [(icon: AnyView, title: String, body: String)] = [
        (AnyView(BookIcon(color: Quill.brassDeep)), "The Goal",
         "Fill every white square so each numbered Across and Down clue is answered correctly. When the whole grid is right, the puzzle is solved."),
        (AnyView(QuillIcon(color: Quill.brassDeep)), "Entering Letters",
         "Tap a square to select it and read its clue. Type with the on-screen keyboard; the cursor auto-advances within the current word."),
        (AnyView(ChevronIconWrap()), "Direction & Navigation",
         "Tap a selected square again to switch between its Across and Down clue. The clue-bar arrows step through every clue in order."),
        (AnyView(CheckIcon(color: Quill.correctTint)), "Check",
         "Check a single letter, the current word, or the whole puzzle. Any wrong letters are flagged in red until you fix them."),
        (AnyView(EyeIcon(color: Quill.brass)), "Reveal",
         "Reveal a single letter or an entire word when you are stuck. Solving with no reveals earns a clean-solve star."),
        (AnyView(ClockIcon(color: Quill.inkSoft)), "Daily & Streaks",
         "A new puzzle is chosen each day from the library. Solve the daily puzzle on consecutive days to build your streak. Your best time per puzzle is saved.")
    ]

    var body: some View {
        ZStack {
            ParchmentBackground()
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(0..<sections.count, id: \.self) { i in
                        QuillCard {
                            HStack(alignment: .top, spacing: 14) {
                                sections[i].icon.frame(width: 28, height: 28)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(sections[i].title).font(Quill.titleBold(17)).foregroundColor(Quill.ink)
                                    Text(sections[i].body).font(Quill.body(14)).foregroundColor(Quill.inkSoft)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
        }
        .navigationBarTitle("How to Play", displayMode: .inline)
    }
}

private struct ChevronIconWrap: View {
    var body: some View {
        HStack(spacing: 2) {
            ChevronIcon(color: Quill.brassDeep).frame(width: 14, height: 14).rotationEffect(.degrees(180))
            ChevronIcon(color: Quill.brassDeep).frame(width: 14, height: 14)
        }
    }
}
