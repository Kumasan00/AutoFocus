import SwiftUI

@main
struct AutoFocusApp: App {
    @StateObject private var state: CursorState
    private let monitor: MouseMonitor
    @AppStorage(UserDefaults.Keys.isRun) private var isRun: Bool = true

    init() {
        if !checkAccessibilityPermission(prompt: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NSWorkspace.shared.open(
                    URL(
                        string:
                            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
                    )!
                )
            }
        }

        UserDefaults.standard.register(defaults: [
            "time": 500, "launchAtLogin": false, "isRun": true,
        ])

        let state = CursorState()
        self._state = StateObject(wrappedValue: state)

        let monitor = MouseMonitor(state: state)
        self.monitor = monitor

        if isRun {
            monitor.start()
        } else {
            monitor.stop()
        }
    }

    var body: some Scene {
        MenuBarExtra("AutoFocusApp", systemImage: "iphone.app.switcher") {
            MenubarView()
                .onChange(of: isRun) { _, newValue in
                    if newValue {
                        monitor.start()
                    } else {
                        monitor.stop()
                    }
                }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
        }
    }
}
