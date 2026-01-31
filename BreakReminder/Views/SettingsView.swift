import SwiftUI

struct SettingsView: View {
    @ObservedObject var notificationManager = NotificationManager.shared
    @ObservedObject var launchManager = LaunchManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    if !notificationManager.isAuthorized {
                        PermissionBanner()
                    }

                    // Launch at Login
                    HStack {
                        Image(systemName: "power")
                            .frame(width: 20)
                        Text("Launch at Login")
                        Spacer()
                        Toggle("", isOn: $launchManager.launchAtLogin)
                            .toggleStyle(.switch)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)

                    ForEach(ReminderType.allCases) { type in
                        ReminderSettingRow(type: type)
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                Button("Quit App") {
                    NSApplication.shared.terminate(nil)
                }
                .foregroundColor(.red)

                Spacer()

                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 400, height: 450)
    }
}

struct PermissionBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("Notifications not enabled")
                .font(.subheadline)
            Spacer()
            Button("Enable") {
                NotificationManager.shared.requestAuthorization()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ReminderSettingRow: View {
    let type: ReminderType
    @State private var isEnabled: Bool
    @State private var intervalMinutes: Double

    init(type: ReminderType) {
        self.type = type
        let manager = NotificationManager.shared
        _isEnabled = State(initialValue: manager.isEnabled(for: type))
        _intervalMinutes = State(initialValue: manager.getInterval(for: type) / 60)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: type.systemImage)
                    .frame(width: 20)
                Text(type.displayName)
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .toggleStyle(.switch)
                    .onChange(of: isEnabled) { newValue in
                        NotificationManager.shared.setEnabled(newValue, for: type)
                    }
            }

            if isEnabled {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Remind every:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(intervalMinutes)) minutes")
                            .font(.subheadline)
                            .monospacedDigit()
                    }

                    Slider(
                        value: $intervalMinutes,
                        in: (type.minInterval / 60)...(type.maxInterval / 60),
                        step: 5
                    )
                    .onChange(of: intervalMinutes) { newValue in
                        NotificationManager.shared.setInterval(newValue * 60, for: type)
                    }

                    HStack {
                        Text("\(Int(type.minInterval / 60)) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(type.maxInterval / 60)) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Button("Test Notification") {
                    NotificationManager.shared.sendTestNotification(for: type)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

#Preview {
    SettingsView()
}
