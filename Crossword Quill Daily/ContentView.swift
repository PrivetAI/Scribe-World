import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: QuillStore
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(StackNavigationViewStyle())

            if showOnboarding {
                OnboardingView(onFinish: {
                    store.settings.onboardingDone = true
                    store.saveSettings()
                    withAnimation { showOnboarding = false }
                })
                .transition(.opacity)
            }
        }
        .onAppear {
            store.refreshDailyState()
            if !store.settings.onboardingDone {
                showOnboarding = true
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var store: QuillStore
    private let library = AppLibrary.shared

    @State private var goDaily = false
    @State private var goContinue = false
    @State private var goPacks = false
    @State private var goSettings = false
    @State private var goHowTo = false

    private var dailyPuzzle: Puzzle { library.dailyPuzzle() }
    private var continuePuzzle: Puzzle? {
        guard let id = store.lastPlayedPuzzleID,
              let p = library.puzzle(by: id),
              !store.isCompleted(id) else { return nil }
        return p
    }

    var body: some View {
        ZStack {
            ParchmentBackground()
            ScrollView {
                VStack(spacing: 18) {
                    header
                    statsRow
                    dailyCard
                    if let cont = continuePuzzle {
                        continueCard(cont)
                    }
                    packsButton
                    bottomRow
                    Spacer(minLength: 10)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }

            // hidden navigation links
            navLinks
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }

    private var navLinks: some View {
        Group {
            NavigationLink(destination: GameView(puzzle: dailyPuzzle, store: store, isDaily: true), isActive: $goDaily) { EmptyView() }
            NavigationLink(destination: continueDestination, isActive: $goContinue) { EmptyView() }
            NavigationLink(destination: PacksView(), isActive: $goPacks) { EmptyView() }
            NavigationLink(destination: SettingsView(), isActive: $goSettings) { EmptyView() }
            NavigationLink(destination: HowToPlayView(), isActive: $goHowTo) { EmptyView() }
        }
        .hidden()
    }

    @ViewBuilder
    private var continueDestination: some View {
        if let cont = continuePuzzle {
            GameView(puzzle: cont, store: store, isDaily: false)
        } else {
            EmptyView()
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().fill(Quill.panel).frame(width: 66, height: 66)
                    .overlay(Circle().strokeBorder(Quill.brass.opacity(0.4), lineWidth: 1.5))
                QuillIcon(color: Quill.brassDeep).frame(width: 38, height: 38)
            }
            Text("Crossword Quill")
                .font(Quill.titleBold(28))
                .foregroundColor(Quill.ink)
            Text("D A I L Y")
                .font(Quill.body(12))
                .tracking(4)
                .foregroundColor(Quill.brassDeep)
        }
        .padding(.bottom, 2)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(store.totalSolved)", label: "Solved")
            statCard(value: "\(store.daily.currentStreak)", label: "Streak")
            statCard(value: "\(store.daily.bestStreak)", label: "Best")
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(Quill.titleBold(24)).foregroundColor(Quill.ink)
            Text(label).font(Quill.body(12)).foregroundColor(Quill.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Quill.panel)
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Quill.brass.opacity(0.3), lineWidth: 1))
        )
    }

    private var dailyCard: some View {
        Button(action: { goDaily = true }) {
            QuillCard {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(Quill.brass.opacity(0.16)).frame(width: 56, height: 56)
                        BookIcon(color: Quill.brassDeep).frame(width: 32, height: 32)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Daily Puzzle").font(Quill.titleBold(19)).foregroundColor(Quill.ink)
                            if store.daily.solvedToday {
                                StarIcon(filled: true, color: Quill.star).frame(width: 15, height: 15)
                            }
                        }
                        Text(store.daily.solvedToday ? "Solved today — replay" : dailyPuzzle.title)
                            .font(Quill.body(14)).foregroundColor(Quill.inkSoft)
                        Text(dateLine).font(Quill.body(12)).foregroundColor(Quill.brassDeep)
                    }
                    Spacer()
                    ChevronIcon(color: Quill.brass).frame(width: 18, height: 18)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func continueCard(_ p: Puzzle) -> some View {
        Button(action: { goContinue = true }) {
            QuillCard {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(Quill.quillBlue.opacity(0.16)).frame(width: 56, height: 56)
                        PlayIcon(color: Quill.quillBlue).frame(width: 26, height: 26)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Continue").font(Quill.titleBold(19)).foregroundColor(Quill.ink)
                        Text("\(p.pack) · \(p.title)").font(Quill.body(14)).foregroundColor(Quill.inkSoft)
                    }
                    Spacer()
                    ChevronIcon(color: Quill.brass).frame(width: 18, height: 18)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var packsButton: some View {
        Button(action: { goPacks = true }) {
            QuillCard {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(Quill.brass.opacity(0.16)).frame(width: 56, height: 56)
                        InkwellIcon(color: Quill.quillBlue).frame(width: 32, height: 32)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Puzzle Packs").font(Quill.titleBold(19)).foregroundColor(Quill.ink)
                        Text("\(library.packs.count) themed collections · \(library.totalPuzzles) puzzles")
                            .font(Quill.body(13)).foregroundColor(Quill.inkSoft)
                    }
                    Spacer()
                    ChevronIcon(color: Quill.brass).frame(width: 18, height: 18)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var bottomRow: some View {
        HStack(spacing: 12) {
            Button(action: { goHowTo = true }) {
                smallTile(icon: AnyView(BookIcon(color: Quill.brassDeep)), label: "How to Play")
            }
            .buttonStyle(PlainButtonStyle())
            Button(action: { goSettings = true }) {
                smallTile(icon: AnyView(GearIcon(color: Quill.brassDeep)), label: "Settings")
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func smallTile(icon: AnyView, label: String) -> some View {
        VStack(spacing: 8) {
            icon.frame(width: 26, height: 26)
            Text(label).font(Quill.body(14)).foregroundColor(Quill.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Quill.panel)
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Quill.brass.opacity(0.3), lineWidth: 1))
        )
    }

    private var dateLine: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: Date())
    }
}
