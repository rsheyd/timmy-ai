import AppKit
import SwiftUI

final class ChatWindowController: NSWindowController {
    private var hosting: NSHostingView<ChatView>?

    convenience init() {
        let contentView = ChatView()
        let hosting = NSHostingView(rootView: contentView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 520),
            styleMask: [.titled, .fullSizeContentView, .closable],
            backing: .buffered,
            defer: false
        )
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.contentView = hosting

        self.init(window: window)
        self.hosting = hosting
    }
    
    // MARK: - Context injection

    func setContextSnapshot(_ snapshot: ContextSnapshot?) {
        hosting?.rootView.contextSnapshot = snapshot
    }
    
    // MARK: - Presentation

    func present() {
        guard let window = self.window else { return }
        if !window.isVisible {
            window.center()
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        self.window?.orderOut(nil)
    }
}
