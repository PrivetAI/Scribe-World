import SwiftUI

struct GameView: View {
    @EnvironmentObject var store: ScribeStore
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var session: GameSession
    let isDaily: Bool

    @State private var showTools = false
    @State private var showCompletion = false
    @State private var didRegister = false

    init(puzzle: Puzzle, store: ScribeStore, isDaily: Bool) {
        self.isDaily = isDaily
        let p = store.progress(for: puzzle.id)
        var saved: [[Character]]? = nil
        if p.started, p.letters.count == puzzle.rows {
            saved = p.letters.map { Array($0) }
        }
        _session = StateObject(wrappedValue: GameSession(
            puzzle: puzzle,
            savedLetters: saved,
            elapsed: p.completed ? 0 : p.elapsed,
            usedReveal: p.usedReveal
        ))
    }

    var body: some View {
        GeometryReader { geo in
            let isWide = geo.size.width > geo.size.height
            ZStack {
                ParchmentBackground()
                if isWide {
                    landscapeLayout(geo)
                } else {
                    portraitLayout(geo)
                }

                if session.isPaused {
                    pauseOverlay
                }
                if showCompletion {
                    CompletionOverlay(
                        time: session.elapsed,
                        clean: session.cleanSolve,
                        bestTime: store.progress(for: session.puzzle.id).bestTime,
                        onContinue: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear {
            session.startTimer()
            store.setLastPlayed(session.puzzle.id)
        }
        .onDisappear {
            persist()
            session.stopTimer()
        }
        .onReceive(session.$solved) { solved in
            if solved && !didRegister {
                didRegister = true
                store.markCompleted(id: session.puzzle.id,
                                    time: session.elapsed,
                                    clean: session.cleanSolve,
                                    isDaily: isDaily)
                Haptics.success(store)
                withAnimation(.easeInOut(duration: 0.4)) { showCompletion = true }
            }
        }
    }

    private func persist() {
        store.updateProgress(id: session.puzzle.id,
                             letters: session.enteredStrings(),
                             elapsed: session.elapsed,
                             usedReveal: session.usedReveal)
    }

    // MARK: Layouts

    private func portraitLayout(_ geo: GeometryProxy) -> some View {
        let avail = min(geo.size.width - 24, geo.size.height * 0.5)
        let cell = (avail / CGFloat(session.puzzle.cols))
        return VStack(spacing: 10) {
            topBar
            clueBar
            GridView(session: session, cellSize: cell)
                .frame(width: cell * CGFloat(session.puzzle.cols),
                       height: cell * CGFloat(session.puzzle.rows))
                .padding(.vertical, 4)
            toolRow
            Spacer(minLength: 0)
            ScribeKeyboard(
                onLetter: { ch in session.type(ch); Haptics.tap(store); persist() },
                onBackspace: { session.backspace(); Haptics.tap(store); persist() }
            )
            .padding(.horizontal, 6)
            .padding(.bottom, 4)
        }
        .padding(.horizontal, 12)
    }

    private func landscapeLayout(_ geo: GeometryProxy) -> some View {
        let avail = min(geo.size.height - 70, geo.size.width * 0.42)
        let cell = avail / CGFloat(session.puzzle.cols)
        return VStack(spacing: 6) {
            topBar
            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 8) {
                    clueBar
                    GridView(session: session, cellSize: cell)
                        .frame(width: cell * CGFloat(session.puzzle.cols),
                               height: cell * CGFloat(session.puzzle.rows))
                }
                VStack(spacing: 8) {
                    toolRow
                    ScribeKeyboard(
                        onLetter: { ch in session.type(ch); Haptics.tap(store); persist() },
                        onBackspace: { session.backspace(); Haptics.tap(store); persist() }
                    )
                }
                .frame(maxWidth: .infinity)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: {
                persist()
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 4) {
                    ChevronIcon(color: Scribe.brassDeep)
                        .frame(width: 16, height: 16)
                        .rotationEffect(.degrees(180))
                    Text("Back").font(Scribe.body(15)).foregroundColor(Scribe.brassDeep)
                }
            }
            Spacer()
            Text(session.puzzle.title)
                .font(Scribe.titleBold(17))
                .foregroundColor(Scribe.ink)
                .lineLimit(1)
            Spacer()
            HStack(spacing: 6) {
                ClockIcon(color: Scribe.inkSoft).frame(width: 16, height: 16)
                Text(timeString(session.elapsed))
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundColor(Scribe.inkSoft)
            }
            Button(action: { session.togglePause() }) {
                ZStack {
                    Circle().fill(Scribe.brass).frame(width: 30, height: 30)
                    PauseIcon(color: Scribe.panel).frame(width: 13, height: 13)
                }
            }
        }
        .padding(.top, 6)
    }

    // MARK: Clue bar with prev/next

    private var clueBar: some View {
        let entry = session.currentEntry
        return HStack(spacing: 10) {
            Button(action: { session.prevClue(); persist() }) {
                navArrow(left: true)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.map { "\($0.number) \($0.isAcross ? "Across" : "Down")" } ?? "")
                    .font(Scribe.body(12))
                    .foregroundColor(Scribe.brassDeep)
                Text(entry?.clue ?? "Select a cell")
                    .font(Scribe.title(16))
                    .foregroundColor(Scribe.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: { session.nextClue(); persist() }) {
                navArrow(left: false)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Scribe.panel)
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Scribe.brass.opacity(0.3), lineWidth: 1))
        )
    }

    private func navArrow(left: Bool) -> some View {
        ZStack {
            Circle().fill(Scribe.parchmentDeep).frame(width: 30, height: 30)
            ChevronIcon(color: Scribe.brassDeep)
                .frame(width: 14, height: 14)
                .rotationEffect(.degrees(left ? 180 : 0))
        }
    }

    // MARK: Tool row

    private var toolRow: some View {
        HStack(spacing: 8) {
            toolButton(label: "Check", icon: AnyView(CheckIcon(color: Scribe.correctTint))) {
                showTools = true
            }
            .actionSheet(isPresented: $showTools) {
                ActionSheet(title: Text("Tools"), buttons: [
                    .default(Text("Check Letter")) { session.checkLetter(); Haptics.tap(store) },
                    .default(Text("Check Word")) { session.checkWord(); Haptics.tap(store) },
                    .default(Text("Check Puzzle")) { session.checkPuzzle(); Haptics.tap(store) },
                    .default(Text("Reveal Letter")) { session.revealLetter(); Haptics.tap(store); persist() },
                    .default(Text("Reveal Word")) { session.revealWord(); Haptics.tap(store); persist() },
                    .destructive(Text("Clear Puzzle")) { session.clearPuzzle(); persist() },
                    .cancel()
                ])
            }
            toolButton(label: "Reveal", icon: AnyView(EyeIcon(color: Scribe.brass))) {
                session.revealLetter(); Haptics.tap(store); persist()
            }
            toolButton(label: "Clear", icon: AnyView(ClearIcon(color: Scribe.inkSoft))) {
                session.clearPuzzle(); persist()
            }
        }
    }

    private func toolButton(label: String, icon: AnyView, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                icon.frame(width: 18, height: 18)
                Text(label).font(Scribe.body(14)).foregroundColor(Scribe.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10).fill(Scribe.panel)
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Scribe.brass.opacity(0.3), lineWidth: 1))
            )
        }
    }

    // MARK: Pause overlay

    private var pauseOverlay: some View {
        ZStack {
            Scribe.ink.opacity(0.55).edgesIgnoringSafeArea(.all)
            ScribeCard {
                VStack(spacing: 18) {
                    Text("Paused").font(Scribe.titleBold(26)).foregroundColor(Scribe.ink)
                    Text(timeString(session.elapsed))
                        .font(.system(size: 22, weight: .medium, design: .monospaced))
                        .foregroundColor(Scribe.inkSoft)
                    Button(action: { session.togglePause() }) {
                        HStack(spacing: 8) {
                            PlayIcon(color: Scribe.panel).frame(width: 16, height: 16)
                            Text("Resume").font(Scribe.title(18)).foregroundColor(Scribe.panel)
                        }
                        .padding(.horizontal, 28).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Scribe.brass))
                    }
                }
                .padding(8)
            }
            .frame(maxWidth: 280)
        }
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}
