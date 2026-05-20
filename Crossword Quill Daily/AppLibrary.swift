import Foundation

// Singleton holding the validated puzzle library.
// At launch it validates every puzzle: in DEBUG via assertions, and always
// via a guard that skips/logs any invalid puzzle so release never crashes.
final class AppLibrary {
    static let shared = AppLibrary()

    let packs: [PuzzlePack]

    private let byID: [String: Puzzle]
    private let allPuzzles: [Puzzle]

    private init() {
        let rawPacks = PuzzleLibrary.buildPacks()
        var validPacks: [PuzzlePack] = []
        var allValid: [Puzzle] = []

        for pack in rawPacks {
            var keep: [Puzzle] = []
            for puzzle in pack.puzzles {
                if let err = puzzle.validationError() {
                    // DEBUG: fail loudly so authoring bugs are caught in builds.
                    assertionFailure("Invalid puzzle \(puzzle.id): \(err)")
                    // Release: skip invalid puzzle, log, keep app alive.
                    print("[Quill] Skipping invalid puzzle \(puzzle.id): \(err)")
                    continue
                }
                keep.append(puzzle)
                allValid.append(puzzle)
            }
            if !keep.isEmpty {
                validPacks.append(PuzzlePack(id: pack.id, name: pack.name, puzzles: keep))
            }
        }

        self.packs = validPacks
        self.allPuzzles = allValid
        var map: [String: Puzzle] = [:]
        for p in allValid { map[p.id] = p }
        self.byID = map
    }

    var totalPuzzles: Int { allPuzzles.count }
    var totalClues: Int { allPuzzles.reduce(0) { $0 + $1.totalClues } }

    func puzzle(by id: String) -> Puzzle? { byID[id] }

    // Date-seeded daily pick from the whole library.
    func dailyPuzzle(date: Date = Date()) -> Puzzle {
        guard !allPuzzles.isEmpty else {
            // Should never happen; provide a tiny fallback to keep types safe.
            return Puzzle(id: "fallback", pack: "Everyday", title: "Puzzle",
                          rows: 0, cols: 0, pattern: [], solution: [],
                          across: [], down: [], cellNumbers: [:])
        }
        let idx = DailySeed.dailyIndex(count: allPuzzles.count, date: date)
        return allPuzzles[idx]
    }

    func pack(by id: String) -> PuzzlePack? { packs.first { $0.id == id } }
}
