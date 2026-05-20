import SwiftUI

struct PuzzleSelectView: View {
    @EnvironmentObject var store: QuillStore
    let pack: PuzzlePack

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 14)]

    var body: some View {
        ZStack {
            ParchmentBackground()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(Array(pack.puzzles.enumerated()), id: \.element.id) { idx, puzzle in
                        NavigationLink(destination: GameView(puzzle: puzzle, store: store, isDaily: false)) {
                            puzzleTile(index: idx + 1, puzzle: puzzle)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
        }
        .navigationBarTitle(pack.name, displayMode: .inline)
    }

    private func puzzleTile(index: Int, puzzle: Puzzle) -> some View {
        let prog = store.progress(for: puzzle.id)
        let completed = prog.completed
        return VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(completed ? Quill.brass.opacity(0.18) : Quill.panel)
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Quill.brass.opacity(completed ? 0.5 : 0.3), lineWidth: 1)
                VStack(spacing: 5) {
                    Text("\(index)")
                        .font(Quill.titleBold(26))
                        .foregroundColor(Quill.ink)
                    Text("\(puzzle.rows)×\(puzzle.cols)")
                        .font(Quill.body(11))
                        .foregroundColor(Quill.inkSoft)
                }
                if completed {
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle().fill(Quill.brass).frame(width: 22, height: 22)
                                if prog.clean {
                                    StarIcon(filled: true, color: Quill.panel).frame(width: 12, height: 12)
                                } else {
                                    CheckIcon(color: Quill.panel).frame(width: 12, height: 12)
                                }
                            }
                            .padding(6)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 86)
            Text(puzzle.title)
                .font(Quill.body(12))
                .foregroundColor(Quill.inkSoft)
                .lineLimit(1)
            if completed && prog.bestTime > 0 {
                Text(timeString(prog.bestTime))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Quill.brassDeep)
            }
        }
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}
