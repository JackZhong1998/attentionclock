import AppKit
import SwiftUI

@MainActor
final class FloatingCatWindowController {
    static let shared = FloatingCatWindowController()

    private var panel: NSPanel?
    private var hostingView: NSHostingView<FloatingCatView>?
    private var settings: SettingsStore?
    private var dragOriginStart: NSPoint?

    private init() {}

    func sync(
        enabled: Bool,
        settings: SettingsStore,
        petStore: PetStore,
        catStore: CatStore,
        timer: TimerViewModel
    ) {
        self.settings = settings
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
        dragOriginStart = nil
    }

    func handleDrag(translation: CGSize) {
        guard let panel else { return }
        if dragOriginStart == nil {
            dragOriginStart = panel.frame.origin
        }
        guard let start = dragOriginStart else { return }

        let proposed = NSPoint(
            x: start.x + translation.width,
            y: start.y - translation.height
        )
        panel.setFrameOrigin(clampedOrigin(proposed, for: panel))
    }

    func endDrag() {
        dragOriginStart = nil
        savePanelPosition()
    }

    private func showPanel(petStore: PetStore, catStore: CatStore, timer: TimerViewModel) {
        if panel == nil {
            let newPanel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 168, height: 180),
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
            panel = newPanel
        }

        let rootView = FloatingCatView(petStore: petStore, catStore: catStore, timer: timer)
        if let hostingView, let panel {
            hostingView.rootView = rootView
            fitPanelToContent(hostingView: hostingView, panel: panel)
        } else if let panel {
            let view = NSHostingView(rootView: rootView)
            hostingView = view
            panel.contentView = view
            fitPanelToContent(hostingView: view, panel: panel)
            panel.setFrameOrigin(resolvedOrigin(for: panel))
        }

        panel?.orderFrontRegardless()
    }

    private func fitPanelToContent(hostingView: NSHostingView<FloatingCatView>, panel: NSPanel) {
        let previousOrigin = panel.frame.origin
        hostingView.layoutSubtreeIfNeeded()
        let size = hostingView.fittingSize
        let contentSize = NSSize(width: max(size.width, 168), height: max(size.height, 120))
        panel.setContentSize(contentSize)
        hostingView.frame = NSRect(origin: .zero, size: contentSize)
        panel.setFrameOrigin(clampedOrigin(previousOrigin, for: panel))
    }

    private func resolvedOrigin(for panel: NSPanel) -> NSPoint {
        if let settings, settings.floatingCatPositionSaved {
            let saved = NSPoint(x: settings.floatingCatOriginX, y: settings.floatingCatOriginY)
            return clampedOrigin(saved, for: panel)
        }
        return defaultOrigin(for: panel)
    }

    private func defaultOrigin(for panel: NSPanel) -> NSPoint {
        guard let screen = NSScreen.main else { return panel.frame.origin }
        let visible = screen.visibleFrame
        return NSPoint(
            x: visible.maxX - panel.frame.width - 14,
            y: visible.minY + 72
        )
    }

    private func clampedOrigin(_ origin: NSPoint, for panel: NSPanel) -> NSPoint {
        let screen = NSScreen.screens.first { screen in
            screen.frame.contains(origin)
        } ?? NSScreen.main
        guard let visible = screen?.visibleFrame else { return origin }

        let maxX = visible.maxX - panel.frame.width
        let maxY = visible.maxY - panel.frame.height
        return NSPoint(
            x: min(max(origin.x, visible.minX), maxX),
            y: min(max(origin.y, visible.minY), maxY)
        )
    }

    private func savePanelPosition() {
        guard let panel, let settings else { return }
        settings.floatingCatOriginX = panel.frame.origin.x
        settings.floatingCatOriginY = panel.frame.origin.y
        settings.floatingCatPositionSaved = true
    }
}
