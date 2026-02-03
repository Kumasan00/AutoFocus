import Combine
import SwiftUI

final class CursorState: ObservableObject {
    @Published var position: CGPoint = .zero
    @Published var isDragging: Bool = false
    @Published var isMoving: Bool = false
}
