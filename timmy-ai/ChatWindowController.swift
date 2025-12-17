import AppKit
import SwiftUI

final class ChatWindowController: NSWindowController {
    private let contextModel: ContextModel
    private var hosting: NSHostingView<ChatView>?

    override init(window: NSWindow?) {
        // Fallback init to satisfy NSWindowController's designated initializer
        self.contextModel = ContextModel()
        super.init(window: window)
    }

    convenience init() {
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

        self.init(window: window)

        let contentView = ChatView(context: self.contextModel)
        let hosting = NSHostingView(rootView: contentView)
        window.contentView = hosting
        self.hosting = hosting
    }

    required init?(coder: NSCoder) {
        self.contextModel = ContextModel()
        super.init(coder: coder)
    }
    
    // MARK: - Context injection

    func setContextSnapshot(_ snapshot: ContextSnapshot?) {
        contextModel.snapshot = snapshot
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
