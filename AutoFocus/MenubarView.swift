import SwiftUI

struct MenubarView: View {
    @AppStorage(UserDefaults.Keys.isRun) private var isRun: Bool = true

    var body: some View {
        VStack(spacing: 4) {
            Button {
                isRun.toggle()
            } label: {
                Text(isRun ? "stop" : "start")
                    .frame(maxWidth: .infinity)
            }

            Divider()

            SettingsLink {
                Text("open settings")
                    .frame(maxWidth: .infinity)
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("quit")
                    .frame(maxWidth: .infinity)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .frame(width: 160)
        .padding(8)
    }
}
