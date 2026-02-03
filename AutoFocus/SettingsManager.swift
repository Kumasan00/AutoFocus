import Combine
import ServiceManagement
import SwiftUI

@MainActor
class SettingsManager: ObservableObject {
  static let shared = SettingsManager()

  private init() {}

  func updateLaunchAtLogin(enabled: Bool) {
    let service = SMAppService.mainApp

    do {
      if enabled {
        try service.register()
        print("ログイン時の起動を有効にしました")
      } else {
        try service.unregister()
        print("ログイン時の起動を無効にしました")
      }

      if UserDefaults.standard.launchAtLogin != enabled {
        UserDefaults.standard.launchAtLogin = enabled
      }
    } catch {
      print("設定の変更に失敗しました: \(error)")
      UserDefaults.standard.launchAtLogin = !enabled
    }
  }
}

extension UserDefaults {
  enum Keys {
    static let launchAtLogin = "launchAtLogin"
    static let isRun = "isRun"
    static let time = "time"
  }

  var launchAtLogin: Bool {
    get {
      bool(forKey: Keys.launchAtLogin)
    }
    set {
      set(newValue, forKey: Keys.launchAtLogin)
    }
  }

  var isRun: Bool {
    get {
      bool(forKey: Keys.isRun)
    }
    set {
      set(newValue, forKey: Keys.isRun)
    }
  }

  var time: Double {
    get {
      double(forKey: Keys.time)
    }
    set {
      set(newValue, forKey: Keys.time)
    }
  }
}
