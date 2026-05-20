import SwiftUI

struct PacksView: View {
    @EnvironmentObject var store: QuillStore
    private let library = AppLibrary.shared

    var body: some View {
        ZStack {
            ParchmentBackground()
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(library.packs) { pack in
                        NavigationLink(destination: PuzzleSelectView(pack: pack)) {
                            packRow(pack)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }
        }
        .navigationBarTitle("Puzzle Packs", displayMode: .inline)
    }

    private func packRow(_ pack: PuzzlePack) -> some View {
        let solved = store.solvedCount(in: pack)
        let total = pack.puzzles.count
        return QuillCard {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(packTint(pack.id).opacity(0.18)).frame(width: 54, height: 54)
                    packIcon(pack.id).frame(width: 30, height: 30)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(pack.name).font(Quill.titleBold(18)).foregroundColor(Quill.ink)
                    progressBar(solved: solved, total: total)
                    Text("\(solved) of \(total) solved").font(Quill.body(12)).foregroundColor(Quill.inkSoft)
                }
                Spacer()
                ChevronIcon(color: Quill.brass).frame(width: 16, height: 16)
            }
        }
    }

    private func progressBar(solved: Int, total: Int) -> some View {
        GeometryReader { geo in
            let frac = total > 0 ? CGFloat(solved) / CGFloat(total) : 0
            ZStack(alignment: .leading) {
                Capsule().fill(Quill.parchmentDeep).frame(height: 6)
                Capsule().fill(Quill.brass).frame(width: max(0, geo.size.width * frac), height: 6)
            }
        }
        .frame(height: 6)
    }

    private func packTint(_ id: String) -> Color {
        switch id {
        case "everyday": return Quill.brass
        case "nature": return Quill.correctTint
        case "science": return Quill.quillBlue
        case "geography": return Quill.brassDeep
        case "arts-words": return Quill.wrong
        case "food": return Quill.star
        default: return Quill.inkSoft
        }
    }

    @ViewBuilder
    private func packIcon(_ id: String) -> some View {
        switch id {
        case "arts-words": QuillIcon(color: packTint(id))
        case "science": GearIcon(color: packTint(id))
        case "history": BookIcon(color: packTint(id))
        default: BookIcon(color: packTint(id))
        }
    }
}
