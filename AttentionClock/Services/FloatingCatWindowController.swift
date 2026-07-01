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
        petStore: PetStore,
        catStore: CatStore,
        timer: TimerViewModel
    ) {
        if enabled {
            showPanel(petStore: petStore, catStore: catStore, timer: timer)
        } else {
            hidePanel()
        }
    }

    func hidePanel() {
        panel?.orderOut(nil)
        panel = nil
        hostingView = nil
    }

    private func showPanel(petStore: PetStore, catStore: CatStore, timer: TimerViewModel) {
        if panel == nil {
            let newPanel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 158, height: 158),
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
                newPanel.setFrameOrigin(NSPoint(x: screen.maxX - 182, y: screen.minY + 72))
            }

            panel = newPanel
        }

        let rootView = FloatingCatView(petStore: petStore, catStore: catStore, timer: timer)
        if let hostingView {
            hostingView.rootView = rootView
        } else if let panel {
            let view = NSHostingView(rootView: rootView)
            hostingView = view
            panel.contentView = view
        }

        panel?.orderFrontRegardless()
    }
}
