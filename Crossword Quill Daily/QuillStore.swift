import Foundation
import Combine

// Per-puzzle saved progress.
struct PuzzleProgress: Codable {
    var letters: [String] = []      // entered grid rows
    var completed: Bool = false
    var clean: Bool = false         // solved without reveals
    var bestTime: Int = 0           // seconds; 0 = none
    var elapsed: Int = 0            // in-progress timer
    var usedReveal: Bool = false
    var started: Bool = false

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        letters     = (try? c.decodeIfPresent([String].self, forKey: .letters))    ?? []
        completed   = (try? c.decodeIfPresent(Bool.self,     forKey: .completed))  ?? false
        clean       = (try? c.decodeIfPresent(Bool.self,     forKey: .clean))      ?? false
        bestTime    = (try? c.decodeIfPresent(Int.self,      forKey: .bestTime))   ?? 0
        elapsed     = (try? c.decodeIfPresent(Int.self,      forKey: .elapsed))    ?? 0
        usedReveal  = (try? c.decodeIfPresent(Bool.self,     forKey: .usedReveal)) ?? false
        started     = (try? c.decodeIfPresent(Bool.self,     forKey: .started))    ?? false
    }
}

struct QuillSettings: Codable {
    var sound: Bool = true
    var haptics: Bool = true
    var onboardingDone: Bool = false

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        sound         = (try? c.decodeIfPresent(Bool.self, forKey: .sound))         ?? true
        haptics       = (try? c.decodeIfPresent(Bool.self, forKey: .haptics))       ?? true
        onboardingDone = (try? c.decodeIfPresent(Bool.self, forKey: .onboardingDone)) ?? false
    }
}

// Daily streak record.
struct DailyRecord: Codable {
    var lastSolvedDateKey: String = ""   // "20260520"
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var solvedToday: Bool = false

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        lastSolvedDateKey = (try? c.decodeIfPresent(String.self, forKey: .lastSolvedDateKey)) ?? ""
        currentStreak     = (try? c.decodeIfPresent(Int.self,    forKey: .currentStreak))    ?? 0
        bestStreak        = (try? c.decodeIfPresent(Int.self,    forKey: .bestStreak))       ?? 0
        solvedToday       = (try? c.decodeIfPresent(Bool.self,   forKey: .solvedToday))      ?? false
    }
}

final class QuillStore: ObservableObject {
    @Published private(set) var progress: [String: PuzzleProgress] = [:]
    @Published var settings: QuillSettings = QuillSettings()
    @Published private(set) var daily: DailyRecord = DailyRecord()
    @Published var lastPlayedPuzzleID: String? = nil

    private let kProgress = "cqd.progress.v1"
    private let kSettings = "cqd.settings.v1"
    private let kDaily = "cqd.daily.v1"
    private let kLastPlayed = "cqd.lastPlayed.v1"

    private let defaults = UserDefaults.standard

    init() {
        load()
        refreshDailyState()
    }

    // MARK: Load / Save

    private func load() {
        let dec = JSONDecoder()
        if let d = defaults.data(forKey: kProgress),
           let p = try? dec.decode([String: PuzzleProgress].self, from: d) {
            progress = p
        }
        if let d = defaults.data(forKey: kSettings),
           let s = try? dec.decode(QuillSettings.self, from: d) {
            settings = s
        }
        if let d = defaults.data(forKey: kDaily),
           let r = try? dec.decode(DailyRecord.self, from: d) {
            daily = r
        }
        lastPlayedPuzzleID = defaults.string(forKey: kLastPlayed)
    }

    private func saveProgress() {
        if let d = try? JSONEncoder().encode(progress) {
            defaults.set(d, forKey: kProgress)
        }
    }
    func saveSettings() {
        if let d = try? JSONEncoder().encode(settings) {
            defaults.set(d, forKey: kSettings)
        }
    }
    private func saveDaily() {
        if let d = try? JSONEncoder().encode(daily) {
            defaults.set(d, forKey: kDaily)
        }
    }

    // MARK: Progress accessors

    func progress(for id: String) -> PuzzleProgress {
        progress[id] ?? PuzzleProgress()
    }

    func isCompleted(_ id: String) -> Bool {
        progress[id]?.completed ?? false
    }

    func setLastPlayed(_ id: String) {
        lastPlayedPuzzleID = id
        defaults.set(id, forKey: kLastPlayed)
    }

    // Save in-progress state (called periodically / on leave).
    func updateProgress(id: String, letters: [String], elapsed: Int, usedReveal: Bool) {
        var p = progress(for: id)
        p.letters = letters
        p.elapsed = elapsed
        p.usedReveal = usedReveal
        p.started = true
        progress[id] = p
        saveProgress()
    }

    // Mark solved; updates best time, clean flag, daily streak if this is the daily puzzle.
    func markCompleted(id: String, time: Int, clean: Bool, isDaily: Bool) {
        var p = progress(for: id)
        p.completed = true
        p.started = true
        if clean { p.clean = true }      // sticky clean flag once earned
        if p.bestTime == 0 || time < p.bestTime { p.bestTime = time }
        p.elapsed = 0
        progress[id] = p
        saveProgress()
        if isDaily { registerDailySolve() }
    }

    // MARK: Daily

    private func registerDailySolve() {
        let todayKey = DailySeed.dateKey()
        if daily.lastSolvedDateKey == todayKey {
            daily.solvedToday = true
            saveDaily()
            return
        }
        // determine streak continuity
        if let last = parseKey(daily.lastSolvedDateKey),
           let yesterday = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: dateFromTodayKey(todayKey) ?? Date()) {
            let lastDay = stripTime(last)
            let yDay = stripTime(yesterday)
            if lastDay == yDay {
                daily.currentStreak += 1
            } else {
                daily.currentStreak = 1
            }
        } else {
            daily.currentStreak = 1
        }
        daily.lastSolvedDateKey = todayKey
        daily.solvedToday = true
        if daily.currentStreak > daily.bestStreak {
            daily.bestStreak = daily.currentStreak
        }
        saveDaily()
    }

    func refreshDailyState() {
        let todayKey = DailySeed.dateKey()
        daily.solvedToday = (daily.lastSolvedDateKey == todayKey)
        // streak break: if last solved is older than yesterday, current streak lapses (display 0 if not today/yesterday)
        if !daily.lastSolvedDateKey.isEmpty,
           let last = parseKey(daily.lastSolvedDateKey) {
            let cal = Calendar(identifier: .gregorian)
            if let days = cal.dateComponents([.day], from: stripTime(last), to: stripTime(Date())).day, days > 1 {
                daily.currentStreak = 0
            }
        }
        saveDaily()
    }

    private func parseKey(_ key: String) -> Date? {
        guard key.count == 8, let y = Int(key.prefix(4)),
              let m = Int(key.dropFirst(4).prefix(2)),
              let d = Int(key.suffix(2)) else { return nil }
        var comps = DateComponents()
        comps.year = y; comps.month = m; comps.day = d
        return Calendar(identifier: .gregorian).date(from: comps)
    }
    private func dateFromTodayKey(_ key: String) -> Date? { parseKey(key) }
    private func stripTime(_ date: Date) -> Date {
        let cal = Calendar(identifier: .gregorian)
        return cal.startOfDay(for: date)
    }

    // MARK: Stats

    var totalSolved: Int {
        progress.values.filter { $0.completed }.count
    }

    func solvedCount(in pack: PuzzlePack) -> Int {
        pack.puzzles.filter { isCompleted($0.id) }.count
    }

    // MARK: Reset

    func resetAll() {
        progress = [:]
        daily = DailyRecord()
        lastPlayedPuzzleID = nil
        defaults.removeObject(forKey: kProgress)
        defaults.removeObject(forKey: kDaily)
        defaults.removeObject(forKey: kLastPlayed)
        // keep settings (sound/haptics) but onboarding stays done
    }
}
