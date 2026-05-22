import SwiftUI
import Combine

// Live game state for one puzzle solve.
final class GameSession: ObservableObject {
    let puzzle: Puzzle

    // entered[row][col] = letter or " " (empty). Block cells stay "".
    @Published var entered: [[Character]]
    @Published var selected: GridPos
    @Published var isAcross: Bool
    @Published var wrongCells: Set<GridPos> = []      // flagged by Check
    @Published var revealedCells: Set<GridPos> = []   // filled by Reveal
    @Published var elapsed: Int = 0                   // seconds
    @Published var isPaused: Bool = false
    @Published var solved: Bool = false
    @Published var usedReveal: Bool = false

    private var timer: AnyCancellable?

    init(puzzle: Puzzle, savedLetters: [[Character]]? = nil, elapsed: Int = 0, usedReveal: Bool = false) {
        self.puzzle = puzzle
        if let saved = savedLetters, saved.count == puzzle.rows {
            self.entered = saved
        } else {
            self.entered = (0..<puzzle.rows).map { r in
                (0..<puzzle.cols).map { c in
                    puzzle.isBlock(r, c) ? Character("#") : Character(" ")
                }
            }
        }
        self.elapsed = elapsed
        self.usedReveal = usedReveal
        // initial selection: first white cell
        var start = GridPos(row: 0, col: 0)
        outer: for r in 0..<puzzle.rows {
            for c in 0..<puzzle.cols where !puzzle.isBlock(r, c) {
                start = GridPos(row: r, col: c); break outer
            }
        }
        self.selected = start
        self.isAcross = true
        // ensure a valid direction at start
        if puzzle.entry(at: start, across: true) == nil { self.isAcross = false }
    }

    // MARK: Timer

    func startTimer() {
        guard !solved else { return }
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isPaused, !self.solved else { return }
                self.elapsed += 1
            }
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func togglePause() {
        isPaused.toggle()
    }

    // MARK: Selection

    var currentEntry: CrossEntry? {
        puzzle.entry(at: selected, across: isAcross)
            ?? puzzle.entry(at: selected, across: !isAcross)
    }

    func selectCell(_ pos: GridPos) {
        guard !puzzle.isBlock(pos.row, pos.col) else { return }
        if pos == selected {
            // tap again toggles direction (if other direction exists)
            if puzzle.entry(at: pos, across: !isAcross) != nil {
                isAcross.toggle()
            }
        } else {
            selected = pos
            if puzzle.entry(at: pos, across: isAcross) == nil {
                isAcross.toggle()
            }
        }
    }

    func setDirection(_ across: Bool) {
        if puzzle.entry(at: selected, across: across) != nil {
            isAcross = across
        }
    }

    // MARK: Input

    func type(_ letter: Character) {
        guard !solved, !isPaused else { return }
        let p = selected
        guard !puzzle.isBlock(p.row, p.col) else { return }
        if revealedCells.contains(p) { /* allow overwrite still */ }
        entered[p.row][p.col] = letter
        wrongCells.remove(p)
        advance()
        checkSolved()
    }

    func backspace() {
        guard !solved, !isPaused else { return }
        let p = selected
        if entered[p.row][p.col] != " " && !puzzle.isBlock(p.row, p.col) {
            entered[p.row][p.col] = " "
            wrongCells.remove(p)
        } else {
            retreat()
            let q = selected
            if !puzzle.isBlock(q.row, q.col) {
                entered[q.row][q.col] = " "
                wrongCells.remove(q)
            }
        }
    }

    private func advance() {
        guard let e = currentEntry else { return }
        let cells = e.cells
        guard let idx = cells.firstIndex(of: selected) else { return }
        // advance to next empty cell in entry, else next cell
        if idx + 1 < cells.count {
            // prefer next empty within entry
            for j in (idx + 1)..<cells.count {
                if entered[cells[j].row][cells[j].col] == " " {
                    selected = cells[j]; return
                }
            }
            selected = cells[idx + 1]
        }
    }

    private func retreat() {
        guard let e = currentEntry else { return }
        let cells = e.cells
        guard let idx = cells.firstIndex(of: selected) else { return }
        if idx > 0 { selected = cells[idx - 1] }
    }

    // MARK: Clue navigation

    private var orderedEntries: [CrossEntry] {
        // across first sorted by number, then down
        let a = puzzle.across.sorted { $0.number < $1.number }
        let d = puzzle.down.sorted { $0.number < $1.number }
        return a + d
    }

    func nextClue() {
        let list = orderedEntries
        guard let cur = currentEntry, let i = list.firstIndex(of: cur) else {
            if let f = list.first { focus(f) }; return
        }
        let n = list[(i + 1) % list.count]
        focus(n)
    }

    func prevClue() {
        let list = orderedEntries
        guard let cur = currentEntry, let i = list.firstIndex(of: cur) else {
            if let f = list.first { focus(f) }; return
        }
        let n = list[(i - 1 + list.count) % list.count]
        focus(n)
    }

    func focus(_ e: CrossEntry) {
        isAcross = e.isAcross
        // go to first empty cell of entry, else first
        if let first = e.cells.first(where: { entered[$0.row][$0.col] == " " }) {
            selected = first
        } else {
            selected = e.cells[0]
        }
    }

    // MARK: Tools

    func checkLetter() {
        let p = selected
        guard !puzzle.isBlock(p.row, p.col) else { return }
        if let sol = puzzle.solutionChar(p.row, p.col) {
            if entered[p.row][p.col] != " " && entered[p.row][p.col] != sol {
                wrongCells.insert(p)
            } else {
                wrongCells.remove(p)
            }
        }
    }

    func checkWord() {
        guard let e = currentEntry else { return }
        for p in e.cells {
            if let sol = puzzle.solutionChar(p.row, p.col) {
                if entered[p.row][p.col] != " " && entered[p.row][p.col] != sol {
                    wrongCells.insert(p)
                } else {
                    wrongCells.remove(p)
                }
            }
        }
    }

    func checkPuzzle() {
        for r in 0..<puzzle.rows {
            for c in 0..<puzzle.cols where !puzzle.isBlock(r, c) {
                let p = GridPos(row: r, col: c)
                if let sol = puzzle.solutionChar(r, c) {
                    if entered[r][c] != " " && entered[r][c] != sol {
                        wrongCells.insert(p)
                    } else {
                        wrongCells.remove(p)
                    }
                }
            }
        }
    }

    func revealLetter() {
        let p = selected
        guard !puzzle.isBlock(p.row, p.col) else { return }
        if let sol = puzzle.solutionChar(p.row, p.col) {
            entered[p.row][p.col] = sol
            wrongCells.remove(p)
            revealedCells.insert(p)
            usedReveal = true
        }
        advance()
        checkSolved()
    }

    func revealWord() {
        guard let e = currentEntry else { return }
        for p in e.cells {
            if let sol = puzzle.solutionChar(p.row, p.col) {
                entered[p.row][p.col] = sol
                wrongCells.remove(p)
                revealedCells.insert(p)
            }
        }
        usedReveal = true
        checkSolved()
    }

    func clearPuzzle() {
        for r in 0..<puzzle.rows {
            for c in 0..<puzzle.cols where !puzzle.isBlock(r, c) {
                entered[r][c] = " "
            }
        }
        wrongCells.removeAll()
        revealedCells.removeAll()
    }

    // MARK: Completion

    func isFilled() -> Bool {
        for r in 0..<puzzle.rows {
            for c in 0..<puzzle.cols where !puzzle.isBlock(r, c) {
                if entered[r][c] == " " { return false }
            }
        }
        return true
    }

    func isCorrect() -> Bool {
        for r in 0..<puzzle.rows {
            for c in 0..<puzzle.cols where !puzzle.isBlock(r, c) {
                if entered[r][c] != puzzle.solutionChar(r, c) { return false }
            }
        }
        return true
    }

    private func checkSolved() {
        if isFilled() && isCorrect() {
            solved = true
            stopTimer()
        }
    }

    var cleanSolve: Bool { !usedReveal }

    // entered letters as plain strings for persistence
    func enteredStrings() -> [String] {
        entered.map { String($0) }
    }
}
