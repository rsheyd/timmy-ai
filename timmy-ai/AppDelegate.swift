import AppKit
import Carbon

private var hotKeyRef: EventHotKeyRef?
private var eventHandlerRef: EventHandlerRef?

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var chatWC: ChatWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        chatWC = ChatWindowController()
        registerGlobalHotKey()
        // Uncomment to show on launch:
        // chatWC?.present()
    }

    @objc func toggleChat() {
        guard let chatWC = chatWC else { return }
        if chatWC.window?.isVisible == true {
            chatWC.hide()
        } else {
            chatWC.present()
        }
    }

    func registerGlobalHotKey() {
        // Hotkey: Option + Space
        let modifierKeys = UInt32(optionKey)
        let keyCode = UInt32(kVK_Space)

        let hotKeyID = EventHotKeyID(signature: OSType(bitPattern: 0x54494D59), // 'TIMY'
                                     id: UInt32(1))

        // Install handler once
        let eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))

        let statusInstall = InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var hkCom = EventHotKeyID()
            let status = GetEventParameter(theEvent,
                                           EventParamName(kEventParamDirectObject),
                                           EventParamType(typeEventHotKeyID),
                                           nil,
                                           MemoryLayout<EventHotKeyID>.size,
                                           nil,
                                           &hkCom)
            if status == noErr {
                if hkCom.signature == OSType(bitPattern: 0x54494D59) && hkCom.id == 1 {
                    NSApp.sendAction(#selector(AppDelegate.toggleChat), to: nil, from: nil)
                }
            }
            return noErr
        }, 1, [eventSpec], nil, &eventHandlerRef)

        if statusInstall == noErr {
            RegisterEventHotKey(keyCode, modifierKeys, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        }
    }

    func unregisterGlobalHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
        hotKeyRef = nil
        eventHandlerRef = nil
    }

    func applicationWillTerminate(_ notification: Notification) {
        unregisterGlobalHotKey()
    }
}
