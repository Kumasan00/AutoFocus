import SwiftUI

let mask: CGEventMask =
    (1 << CGEventType.mouseMoved.rawValue)
    | (1 << CGEventType.leftMouseDragged.rawValue)
    | (1 << CGEventType.leftMouseUp.rawValue)

@MainActor
final class MouseMonitor {
    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private let state: CursorState
    private var movingTask: Task<Void, Never>?

    init(state: CursorState) {
        self.state = state
    }

    deinit {
        // Ensure main-actor isolated cleanup from nonisolated deinit
        Task { @MainActor [weak self] in
            self?.stop()
        }
    }

    func start() {
        tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .tailAppendEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: UnsafeMutableRawPointer(
                Unmanaged.passUnretained(self).toOpaque()
            )
        )

        guard let tap else {
            fatalError("Event tap failed")
        }

        source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stop() {
        // Cancel any pending moving timeout
        movingTask?.cancel()
        movingTask = nil

        // Disable and invalidate event tap and source
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            CFRunLoopSourceInvalidate(source)
        }

        // Clear references
        self.tap = nil
        self.source = nil

        // Reset state flags
        state.isMoving = false
        state.isDragging = false
    }

    private let callback: CGEventTapCallBack = { _, type, event, userInfo in
        let monitor = Unmanaged<MouseMonitor>
            .fromOpaque(userInfo!)
            .takeUnretainedValue()

        Task { @MainActor in
            monitor.handle(event: event, type: type)
        }

        return Unmanaged.passUnretained(event)
    }

    private func handle(event: CGEvent, type: CGEventType) {

        let pos = event.location
        state.position = pos

        switch type {
        case .mouseMoved:
            if state.isMoving == false {
                state.isMoving = true
            }
            startMovingTimeout()

        case .leftMouseDragged:
            state.isDragging = true
            if state.isMoving == false {
                state.isMoving = true
            }
            startMovingTimeout()

        case .leftMouseUp:
            state.isDragging = false

        default:
            break
        }
    }

    private func startMovingTimeout() {
        movingTask?.cancel()
        movingTask = Task { [weak self] in
            try? await Task.sleep(
                for: .milliseconds(UserDefaults.standard.time)
            )
            if Task.isCancelled { return }
            if self?.state.isMoving == true {
                self?.state.isMoving = false
                do {
                    try AccessibilityHelper.raiseAndFocusWindow(
                        at: (self?.state.position)!
                    )
                    print("Success: Window raised and focused.")
                } catch {
                    print("Error: \(error)")
                }
            }
            self?.movingTask = nil
        }
    }

}
