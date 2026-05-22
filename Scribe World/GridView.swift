import SwiftUI

// Renders the crossword grid: cells, black squares, numbers, letters,
// active-entry highlight, selected cell, wrong/revealed tints.
struct GridView: View {
    @ObservedObject var session: GameSession
    let cellSize: CGFloat

    private var puzzle: Puzzle { session.puzzle }

    var body: some View {
        let activeCells: Set<GridPos> = Set(session.currentEntry?.cells ?? [])
        VStack(spacing: 0) {
            ForEach(0..<puzzle.rows, id: \.self) { r in
                HStack(spacing: 0) {
                    ForEach(0..<puzzle.cols, id: \.self) { c in
                        cellView(r: r, c: c,
                                 active: activeCells.contains(GridPos(row: r, col: c)))
                    }
                }
            }
        }
        .background(Scribe.cellBlock)
        .overlay(
            Rectangle().strokeBorder(Scribe.ink, lineWidth: 2)
        )
    }

    @ViewBuilder
    private func cellView(r: Int, c: Int, active: Bool) -> some View {
        let pos = GridPos(row: r, col: c)
        if puzzle.isBlock(r, c) {
            Rectangle()
                .fill(Scribe.cellBlock)
                .frame(width: cellSize, height: cellSize)
        } else {
            let isSelected = (pos == session.selected)
            let isWrong = session.wrongCells.contains(pos)
            let isRevealed = session.revealedCells.contains(pos)
            let letter = session.entered[r][c]
            ZStack {
                Rectangle()
                    .fill(cellFill(isSelected: isSelected, active: active, isWrong: isWrong))
                Rectangle()
                    .stroke(Scribe.ink.opacity(0.55), lineWidth: 0.6)

                if let n = puzzle.cellNumbers[pos] {
                    VStack {
                        HStack {
                            Text("\(n)")
                                .font(.system(size: max(7, cellSize * 0.26), weight: .semibold))
                                .foregroundColor(Scribe.inkSoft)
                                .padding(.leading, 1.5)
                                .padding(.top, 0.5)
                            Spacer(minLength: 0)
                        }
                        Spacer(minLength: 0)
                    }
                }

                if letter != " " && letter != "#" {
                    Text(String(letter))
                        .font(Scribe.title(cellSize * 0.56))
                        .foregroundColor(isWrong ? Scribe.wrong : (isRevealed ? Scribe.correctTint : Scribe.ink))
                }
            }
            .frame(width: cellSize, height: cellSize)
            .contentShape(Rectangle())
            .onTapGesture {
                session.selectCell(pos)
            }
        }
    }

    private func cellFill(isSelected: Bool, active: Bool, isWrong: Bool) -> Color {
        if isSelected { return Scribe.cellSelected }
        if isWrong { return Scribe.wrong.opacity(0.18) }
        if active { return Scribe.cellActive.opacity(0.65) }
        return Scribe.cellFill
    }
}
