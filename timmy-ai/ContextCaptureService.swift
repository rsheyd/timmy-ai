//
//  ContextCaptureService.swift
//  timmy-ai
//
//  Created by Roman Sheydvasser on 12/16/25.
//

import AppKit
import CoreGraphics
import ApplicationServices

final class ContextCaptureService {

    /// Main entry point: capture a one-time snapshot.
    func capture(topN: Int = 25) -> ContextSnapshot {
        let frontmost = frontmostAppInfo()
        let windows = windowSummaries()

        // Count windows by app
        var counts: [String: Int] = [:]
        for w in windows { counts[w.appName, default: 0] += 1 }

        let sortedCounts: [ContextSnapshot.AppCount] = counts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value { return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending }
                return lhs.value > rhs.value
            }
            .map { .init(appName: $0.key, count: $0.value) }

        // Prefer showing windows that have titles, then by app name
        let topWindows = windows
            .sorted { a, b in
                let aHasTitle = (a.title?.isEmpty == false)
                let bHasTitle = (b.title?.isEmpty == false)
                if aHasTitle != bHasTitle { return aHasTitle && !bHasTitle }
                return a.appName.localizedCaseInsensitiveCompare(b.appName) == .orderedAscending
            }
            .prefix(topN)
            .map { $0 }

        return ContextSnapshot(
            capturedAt: Date(),
            frontmost: frontmost,
            topWindows: Array(topWindows),
            appCounts: sortedCounts
        )
    }

    // MARK: - Frontmost app + (best-effort) focused window title via AX

    private func frontmostAppInfo() -> ContextSnapshot.FrontmostApp {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return .init(name: "Unknown", bundleID: nil, windowTitle: nil)
        }

        let name = app.localizedName ?? "Unknown"
        let bundleID = app.bundleIdentifier

        // Best-effort: if AX permission exists, get focused window title for the frontmost app.
        let title = focusedWindowTitleIfPermitted(for: app.processIdentifier)

        return .init(name: name, bundleID: bundleID, windowTitle: title)
    }

    private func focusedWindowTitleIfPermitted(for pid: pid_t) -> String? {
        guard AXIsProcessTrusted() else { return nil }

        let axApp = AXUIElementCreateApplication(pid)

        var focusedWindowValue: CFTypeRef?
        let wErr = AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &focusedWindowValue)
        guard wErr == .success, let focusedWindowValue else { return nil }

        var titleValue: CFTypeRef?
        let tErr = AXUIElementCopyAttributeValue(focusedWindowValue as! AXUIElement, kAXTitleAttribute as CFString, &titleValue)
        guard tErr == .success, let title = titleValue as? String else { return nil }

        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - System windows (CoreGraphics)

    private func windowSummaries() -> [ContextSnapshot.WindowSummary] {
        // Include everything, but exclude desktop elements (wallpaper, etc.)
        let options: CGWindowListOption = [.optionAll, .excludeDesktopElements]

        guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return []
        }

        let mapped: [ContextSnapshot.WindowSummary] = list.compactMap { dict in
            guard
                let ownerName = dict[kCGWindowOwnerName as String] as? String,
                let layer = dict[kCGWindowLayer as String] as? Int,
                let boundsDict = dict[kCGWindowBounds as String] as? [String: Any]
            else { return nil }

            // Filter to "normal" app windows (layer 0 tends to be real app windows).
            guard layer == 0 else { return nil }

            // Filter out tiny utility windows
            let width = (boundsDict["Width"] as? CGFloat) ?? 0
            let height = (boundsDict["Height"] as? CGFloat) ?? 0
            guard width > 80, height > 80 else { return nil }

            // Title may be missing without Screen Recording permission.
            let rawTitle = (dict[kCGWindowName as String] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let title = (rawTitle?.isEmpty == false) ? rawTitle : nil

            return .init(appName: ownerName, title: title)
        }

        // Deduplicate exact duplicates to reduce noise
        var seen = Set<String>()
        var deduped: [ContextSnapshot.WindowSummary] = []
        deduped.reserveCapacity(mapped.count)

        for w in mapped {
            let key = "\(w.appName)||\(w.title ?? "")"
            if seen.insert(key).inserted {
                deduped.append(w)
            }
        }

        return deduped
    }
}
