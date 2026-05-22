import Foundation

// Deterministic seeded RNG via SplitMix64 integer mixing.
// NEVER uses String.hashValue or Hasher() — daily pick must be stable
// across cold launches. Seed derived from calendar date integer.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    // Bounded integer in 0..<n.
    mutating func int(_ n: Int) -> Int {
        guard n > 0 else { return 0 }
        return Int(next() % UInt64(n))
    }
}

enum DailySeed {
    // seed = year*10000 + month*100 + day
    static func dateInt(_ date: Date = Date()) -> Int {
        let cal = Calendar(identifier: .gregorian)
        let c = cal.dateComponents([.year, .month, .day], from: date)
        let y = c.year ?? 2026
        let m = c.month ?? 1
        let d = c.day ?? 1
        return y * 10000 + m * 100 + d
    }

    static func dateKey(_ date: Date = Date()) -> String {
        return String(dateInt(date))
    }

    // Stable index into a library of `count` puzzles for a given date.
    static func dailyIndex(count: Int, date: Date = Date()) -> Int {
        guard count > 0 else { return 0 }
        var rng = SplitMix64(seed: UInt64(dateInt(date)))
        // mix a couple of times for good distribution
        _ = rng.next()
        return rng.int(count)
    }
}
