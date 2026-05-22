import Foundation

// A single across or down entry.
struct CrossEntry: Hashable {
    let number: Int
    let isAcross: Bool
    let row: Int        // start cell
    let col: Int
    let length: Int
    let answer: String
    let clue: String

    // cells covered by this entry, in order
    var cells: [GridPos] {
        (0..<length).map { i in
            isAcross ? GridPos(row: row, col: col + i) : GridPos(row: row + i, col: col)
        }
    }
}

struct GridPos: Hashable {
    let row: Int
    let col: Int
}

// A complete crossword puzzle: pattern, solution, clues, numbering.
struct Puzzle: Identifiable {
    let id: String          // stable id e.g. "everyday-3"
    let pack: String
    let title: String
    let rows: Int
    let cols: Int
    let pattern: [String]   // '.' white, '#' black
    let solution: [String]  // letters; '#' on black squares
    let across: [CrossEntry]
    let down: [CrossEntry]

    // number to display at a cell start, or nil
    let cellNumbers: [GridPos: Int]

    func isBlock(_ r: Int, _ c: Int) -> Bool {
        guard r >= 0, r < rows, c >= 0, c < cols else { return true }
        let row = Array(pattern[r])
        return row[c] == "#"
    }

    func solutionChar(_ r: Int, _ c: Int) -> Character? {
        guard r >= 0, r < rows, c >= 0, c < cols else { return nil }
        let row = Array(solution[r])
        let ch = row[c]
        return ch == "#" ? nil : ch
    }

    var totalClues: Int { across.count + down.count }

    // Validity check used at launch. Returns nil if valid, else a reason.
    func validationError() -> String? {
        // (d) min entry length 3 + (a) every run>=3 has clue & numbered start
        for e in across + down {
            if e.length < 3 { return "entry < 3 in \(id)" }
            if e.clue.isEmpty { return "missing clue in \(id) #\(e.number)" }
            if cellNumbers[GridPos(row: e.row, col: e.col)] == nil {
                return "no number at start in \(id) #\(e.number)"
            }
        }
        // (b) crossings consistent: solution must equal each entry's answer
        for e in across + down {
            var s = ""
            for p in e.cells {
                guard let ch = solutionChar(p.row, p.col) else { return "block inside entry \(id)" }
                s.append(ch)
            }
            if s != e.answer { return "crossing mismatch \(id) #\(e.number)" }
        }
        // (c) no isolated white cell: every white cell belongs to an entry>=3
        var covered = Set<GridPos>()
        for e in across + down { for p in e.cells { covered.insert(p) } }
        for r in 0..<rows {
            for c in 0..<cols {
                if !isBlock(r, c) && !covered.contains(GridPos(row: r, col: c)) {
                    return "isolated cell in \(id) at \(r),\(c)"
                }
            }
        }
        return nil
    }

    // Entry that contains a cell, in a given direction.
    func entry(at pos: GridPos, across wantAcross: Bool) -> CrossEntry? {
        let list = wantAcross ? across : down
        return list.first { $0.cells.contains(pos) }
    }
}

// A themed pack of puzzles.
struct PuzzlePack: Identifiable {
    let id: String
    let name: String
    let puzzles: [Puzzle]
}
