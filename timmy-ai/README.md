# timmy-ai
My little AI assistant. Can see and interact with my mac screen and windows.

First phase? See a window and can type in it. An ephemeral window for chatting with Timmy. Use ephemeral chat window to ask Timmy to check my nobs todo spreadsheet that's open in chrome and tell me what I should work on next.

# Files

### AppDelegate.swift

**Role**
App lifecycle coordinator and global hotkey manager.

**Key responsibilities**

* Creates and keeps a reference to `ChatWindowController` on launch.
* Registers a global hotkey (**Option + Space**) using Carbon APIs.
* Installs an event handler to listen for `kEventHotKeyPressed` and triggers `toggleChat()`.
* Cleans up the hotkey and event handler on app termination.

**Interaction**

* Calls `ChatWindowController.present()` and `.hide()` to show/hide the chat window.
* Receives launch/terminate hooks through `NSApplicationDelegate`.
* Referenced by `timmy_aiApp` via `@NSApplicationDelegateAdaptor`.


### ChatWindowController.swift

**Role**
Manages the chat window (an `NSWindowController` wrapping SwiftUI content).

**Key responsibilities**

* Creates a floating, titled, transparent-titlebar window sized **420 × 520**.
* Hosts `ChatView` via `NSHostingView`.
* `present()` centers the window if hidden, brings it to the front, and activates the app.
* `hide()` orders the window out.

**Interaction**

* Constructed and stored by `AppDelegate`.
* Called by `AppDelegate.toggleChat()` to show/hide the window.
* Embeds `ChatView` as the window’s content.


### ChatView.swift

**Role**
The SwiftUI UI for the chat interface.

**Key responsibilities**

* Renders a simple chat layout with a scrollable message list and an input field.
* Maintains local state for messages and input.
* On send, appends the user message and a placeholder Timmy response.
* Keyboard shortcut: **Command + Return** triggers send.

**Interaction**

* Embedded in `ChatWindowController` and presented in the floating window.
* Self-contained UI; no direct coupling to the app delegate or menu bar.



### timmy_aiApp.swift

**Role**
App entry point using SwiftUI’s `App` protocol.

**Key responsibilities**

* Adopts `AppDelegate` with `@NSApplicationDelegateAdaptor`, enabling lifecycle and global hotkey support.
* Defines a `MenuBarExtra` with:

  * **Toggle Chat** → calls `appDelegate.toggleChat()`
  * **Quit** → terminates the app

**Interaction**

* Bridges the SwiftUI app model with the AppKit-based `AppDelegate`.
* Provides an alternative UI path to toggle the chat window from the menu bar.


## How everything works together

**App start**

* `timmy_aiApp` launches and wires in `AppDelegate`.
* `AppDelegate.applicationDidFinishLaunching` creates `ChatWindowController` and registers the global hotkey.

**User presses Option + Space**

* Carbon event handler receives `kEventHotKeyPressed`.
* The `EventHotKeyID` is checked.
* `AppDelegate.toggleChat()` is called.
* `ChatWindowController` either `present()`s or `hide()`s the window.
* A floating window containing `ChatView` appears or disappears.

**Menu bar**

* The **Toggle Chat** item calls `appDelegate.toggleChat()`, mirroring the hotkey behavior.

**App quit**

* `AppDelegate.applicationWillTerminate` unregisters the hotkey and removes the event handler.
