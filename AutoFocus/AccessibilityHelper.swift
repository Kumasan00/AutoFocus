import ApplicationServices
import Cocoa

// MARK: - Accessibility Logic

let AccessibilityHelper = ""

enum AXError: Error {
  case apiError(String)
  case elementNotFound
  case windowNotFound
}

enum AccessibilityHelper {
  /// 指定された座標にあるウィンドウを最前面にしてフォーカスする
  static func raiseAndFocusWindow(at point: CGPoint) throws {
    // 1. システム全体のAX要素を取得
    let systemWide = AXUIElementCreateSystemWide()

    // 2. 座標にある要素を取得 (AXUIElementCopyElementAtPosition)
    var elementRaw: AXUIElement?
    let result = AXUIElementCopyElementAtPosition(
      systemWide,
      Float(point.x),
      Float(point.y),
      &elementRaw
    )

    guard result == .success, let leafElement = elementRaw
    else {
      throw AXError.elementNotFound
    }

    // 3. 要素からウィンドウを探す（ボタンなどをクリックした場合、親を辿る必要がある）
    guard
      let windowElement = leafElement.findParent(
        role: kAXWindowRole as CFString
      )
    else {
      throw AXError.windowNotFound
    }

    // 4. ウィンドウの親（アプリケーション）を取得し、アプリを最前面にする (kAXFrontmostAttribute)
    if let appElement = windowElement.findParent(
      role: kAXApplicationRole as CFString
    ) {
      _ = appElement.setValue(
        true,
        for: kAXFrontmostAttribute as CFString
      )
    }

    // 5. ウィンドウをメインにする (kAXMainAttribute)
    _ = windowElement.setValue(true, for: kAXMainAttribute as CFString)
  }
}

// MARK: - AXUIElement Extension (For Readability & Speed)

extension AXUIElement {
  /// 特定のRoleを持つ親要素を再帰的に探す（高速化のためループ処理）
  func findParent(role: CFString) -> AXUIElement? {
    // 自分自身が対象ならそれを返す
    if getRole() == role { return self }

    var currentElement = self

    // 親を辿るループ
    while let parent = currentElement.getParent() {
      if parent.getRole() == role {
        return parent
      }
      currentElement = parent

      // 安全策: システムルートまで行ってしまったら終了
      if let currentRole = currentElement.getRole() as String?, currentRole == kAXSystemWideRole {
        break
      }
    }
    return nil
  }

  /// Roleを取得する
  func getRole() -> CFString? {
    var roleRaw: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(
      self,
      kAXRoleAttribute as CFString,
      &roleRaw
    )
    guard result == .success, let raw = roleRaw else { return nil }
    // Verify the CFTypeRef is a CFString by comparing type IDs before casting
    if CFGetTypeID(raw) == CFStringGetTypeID() {
      return unsafeBitCast(raw, to: CFString.self)
    }
    return nil
  }

  /// 親要素を取得する
  func getParent() -> AXUIElement? {
    var parentRaw: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(
      self,
      kAXParentAttribute as CFString,
      &parentRaw
    )
    guard result == .success, let parent = parentRaw
    else {
      return nil
    }
    // Verify the CFTypeRef is an AXUIElement by comparing type IDs
    if CFGetTypeID(parent) == AXUIElementGetTypeID() {
      return unsafeBitCast(parent, to: AXUIElement.self)
    }
    return nil
  }

  /// 属性値を設定する
  func setValue(_ value: Any, for attribute: CFString) -> Bool {
    let result = AXUIElementSetAttributeValue(
      self,
      attribute,
      value as CFTypeRef
    )
    return result == .success
  }
}
