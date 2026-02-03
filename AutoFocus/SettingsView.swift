import ServiceManagement
import SwiftUI

struct SettingsView: View {
  @AppStorage(UserDefaults.Keys.time)
  private var storedTime: Double = 500
  @AppStorage(UserDefaults.Keys.launchAtLogin)
  private var launchAtLogin: Bool = false

  @State private var displayTime: Double = 500

  var body: some View {
    VStack(spacing: 20) {
      Text("Settings")
        .font(.headline)

      Toggle("Is First Launch", isOn: $launchAtLogin)
        .onChange(of: launchAtLogin) { _, newValue in
          SettingsManager.shared.updateLaunchAtLogin(
            enabled: newValue
          )
        }

      HStack {
        Slider(
          value: $displayTime,
          in: 0 ... 1000,
          step: 10
        ) {
          Text("time [ms]")
        } minimumValueLabel: {
          Text("0")
        } maximumValueLabel: {
          Text("1000")
        } onEditingChanged: { editing in
          if !editing {
            storedTime = displayTime
          }
        }

        Text("\(Int(displayTime))")
          .monospacedDigit()
          .frame(minWidth: 40, alignment: .trailing)
      }
    }
    .padding()
    .onAppear {
      displayTime = storedTime
    }
  }
}
