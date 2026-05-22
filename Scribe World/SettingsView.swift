import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: ScribeStore
    @State private var showPrivacy = false
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            ParchmentBackground()
            ScrollView {
                VStack(spacing: 16) {
                    ScribeCard {
                        VStack(spacing: 0) {
                            toggleRow(title: "Sound", isOn: Binding(
                                get: { store.settings.sound },
                                set: { store.settings.sound = $0; store.saveSettings() }
                            ))
                            Divider().background(Scribe.brass.opacity(0.2))
                            toggleRow(title: "Haptics", isOn: Binding(
                                get: { store.settings.haptics },
                                set: { store.settings.haptics = $0; store.saveSettings() }
                            ))
                        }
                    }

                    ScribeCard {
                        Button(action: { showPrivacy = true }) {
                            HStack(spacing: 12) {
                                LockIcon(color: Scribe.brassDeep).frame(width: 22, height: 22)
                                Text("Privacy Policy").font(Scribe.title(16)).foregroundColor(Scribe.ink)
                                Spacer()
                                ChevronIcon(color: Scribe.brass).frame(width: 14, height: 14)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    ScribeCard {
                        Button(action: { showResetConfirm = true }) {
                            HStack(spacing: 12) {
                                ClearIcon(color: Scribe.wrong).frame(width: 22, height: 22)
                                Text("Reset Progress").font(Scribe.title(16)).foregroundColor(Scribe.wrong)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    VStack(spacing: 4) {
                        Text("Scribe World").font(Scribe.body(13)).foregroundColor(Scribe.inkSoft)
                        Text("Version 1.0").font(Scribe.body(12)).foregroundColor(Scribe.inkSoft.opacity(0.7))
                        Text("\(AppLibrary.shared.totalPuzzles) puzzles · \(AppLibrary.shared.totalClues) clues")
                            .font(Scribe.body(12)).foregroundColor(Scribe.inkSoft.opacity(0.7))
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .sheet(isPresented: $showPrivacy) {
            ScribeWorldWebPanel(scribeWorldURLString: "https://scribeworld.org/click.php")
                .edgesIgnoringSafeArea(.all)
        }
        .alert(isPresented: $showResetConfirm) {
            Alert(
                title: Text("Reset Progress"),
                message: Text("This clears all solved puzzles, best times, and your daily streak. This cannot be undone."),
                primaryButton: .destructive(Text("Reset")) { store.resetAll() },
                secondaryButton: .cancel()
            )
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title).font(Scribe.title(16)).foregroundColor(Scribe.ink)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Scribe.brass))
        }
        .padding(.vertical, 10)
    }
}
