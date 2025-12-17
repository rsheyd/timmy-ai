//
//  ContextSnapshot.swift
//  timmy-ai
//
//  Created by Roman Sheydvasser on 12/16/25.
//

import Foundation

struct ContextSnapshot: Equatable {
    struct WindowSummary: Equatable {
        let appName: String
        let title: String?
    }

    struct FrontmostApp: Equatable {
        let name: String
        let bundleID: String?
        let windowTitle: String?
    }

    struct AppCount: Equatable {
        let appName: String
        let count: Int
    }

    let capturedAt: Date
    let frontmost: FrontmostApp
    let topWindows: [WindowSummary]
    let appCounts: [AppCount]
}

extension ContextSnapshot {
    func asContextBlock(maxWindows: Int = 25, maxCounts: Int = 10) -> String {
        var lines: [String] = []
        lines.append("Frontmost app: \(frontmost.name) (\(frontmost.bundleID ?? "unknown bundle"))")
        if let t = frontmost.windowTitle { lines.append("Frontmost window: \(t)") }

        if !appCounts.isEmpty {
            let counts = appCounts.prefix(maxCounts).map { "\($0.appName) (\($0.count))" }.joined(separator: ", ")
            lines.append("App counts: \(counts)")
        }

        if !topWindows.isEmpty {
            lines.append("Open windows:")
            for w in topWindows.prefix(maxWindows) {
                lines.append("- \(w.appName)\(w.title.map { " — \($0)" } ?? "")")
            }
        }

        return lines.joined(separator: "\n")
    }
}
