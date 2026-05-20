import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: QuillStore
    @State private var showPrivacy = false
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            ParchmentBackground()
            ScrollView {
                VStack(spacing: 16) {
                    QuillCard {
                        VStack(spacing: 0) {
                            toggleRow(title: "Sound", isOn: Binding(
                                get: { store.settings.sound },
                                set: { store.settings.sound = $0; store.saveSettings() }
                            ))
                            Divider().background(Quill.brass.opacity(0.2))
                            toggleRow(title: "Haptics", isOn: Binding(
                                get: { store.settings.haptics },
                                set: { store.settings.haptics = $0; store.saveSettings() }
                            ))
                        }
                    }

                    QuillCard {
                        Button(action: { showPrivacy = true }) {
                            HStack(spacing: 12) {
                                LockIcon(color: Quill.brassDeep).frame(width: 22, height: 22)
                                Text("Privacy Policy").font(Quill.title(16)).foregroundColor(Quill.ink)
                                Spacer()
                                ChevronIcon(color: Quill.brass).frame(width: 14, height: 14)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    QuillCard {
                        Button(action: { showResetConfirm = true }) {
                            HStack(spacing: 12) {
                                ClearIcon(color: Quill.wrong).frame(width: 22, height: 22)
                                Text("Reset Progress").font(Quill.title(16)).foregroundColor(Quill.wrong)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    VStack(spacing: 4) {
                        Text("Crossword Quill Daily").font(Quill.body(13)).foregroundColor(Quill.inkSoft)
                        Text("Version 1.0").font(Quill.body(12)).foregroundColor(Quill.inkSoft.opacity(0.7))
                        Text("\(AppLibrary.shared.totalPuzzles) puzzles · \(AppLibrary.shared.totalClues) clues")
                            .font(Quill.body(12)).foregroundColor(Quill.inkSoft.opacity(0.7))
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
            CrosswordQuillWebPanel(crosswordQuillURLString: "https://example.com")
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
            Text(title).font(Quill.title(16)).foregroundColor(Quill.ink)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Quill.brass))
        }
        .padding(.vertical, 10)
    }
}
