import AppKit
import SwiftUI

@MainActor
final class FloatingCatWindowController {
    static let shared = FloatingCatWindowController()

    private var panel: NSPanel?
    private var hostingView: NSHostingView<FloatingCatView>?

    private init() {}

    func sync(
        enabled: Bool,
        catStore: CatStore,
        timer: TimerViewModel
    ) {
        if enabled {
            showPanel(catStore: catStore, timer: timer)
        } else {
            hidePanel()
        }
    }

    func hidePanel() {
        panel?.orderOut(nil)
        panel = nil
        hostingView = nil
    }

    private func showPanel(catStore: CatStore, timer: TimerViewModel) {
        if panel == nil {
            let newPanel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 140, height: 132),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            newPanel.level = .floating
            newPanel.isOpaque = false
            newPanel.backgroundColor = .clear
            newPanel.hasShadow = false
            newPanel.isMovableByWindowBackground = true
            newPanel.hidesOnDeactivate = false
            newPanel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
            newPanel.acceptsMouseMovedEvents = true

            if let screen = NSScreen.main?.visibleFrame {
                newPanel.setFrameOrigin(NSPoint(x: screen.maxX - 170, y: screen.minY + 72))
            }

            panel = newPanel
        }

        if hostingView == nil, let panel {
            let view = NSHostingView(rootView: FloatingCatView(catStore: catStore, timer: timer))
            hostingView = view
            panel.contentView = view
        }

        panel?.orderFrontRegardless()
    }
}
