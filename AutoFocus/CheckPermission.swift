import ApplicationServices

func checkAccessibilityPermission(prompt: Bool = true) -> Bool {
    let options: CFDictionary =
        [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt
        ] as CFDictionary

    return AXIsProcessTrustedWithOptions(options)
}
