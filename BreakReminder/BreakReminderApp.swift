import SwiftUI

@main
struct BreakReminderApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showSettings = false

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(showSettings: $showSettings)
        } label: {
            Image(systemName: "clock")
        }
        .menuBarExtraStyle(.menu)

        Window("Settings", id: "settings") {
            SettingsView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }

    init() {
        // Request notification permissions on launch
        Task { @MainActor in
            NotificationManager.shared.requestAuthorization()
        }
    }
}

struct MenuBarView: View {
    @Binding var showSettings: Bool
    @ObservedObject var notificationManager = NotificationManager.shared
    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack {
            Text("Break Reminder")
                .font(.headline)

            Divider()

            ForEach(ReminderType.allCases) { type in
                MenuBarReminderRow(type: type)
            }

            Divider()

            Button("Open Settings...") {
                openWindow(id: "settings")
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}

struct MenuBarReminderRow: View {
    let type: ReminderType
    @State private var isEnabled: Bool

    init(type: ReminderType) {
        self.type = type
        _isEnabled = State(initialValue: NotificationManager.shared.isEnabled(for: type))
    }

    var body: some View {
        Toggle(isOn: $isEnabled) {
            HStack {
                Image(systemName: type.systemImage)
                    .frame(width: 16)
                Text(type.displayName)
                Spacer()
                if isEnabled {
                    let minutes = Int(NotificationManager.shared.getInterval(for: type) / 60)
                    Text("\(minutes)m")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .toggleStyle(.checkbox)
        .onChange(of: isEnabled) { newValue in
            NotificationManager.shared.setEnabled(newValue, for: type)
        }
    }
}
