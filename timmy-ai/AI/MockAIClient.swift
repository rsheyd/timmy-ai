//
//  MockAIClient.swift
//  timmy-ai
//
//  Created by Roman Sheydvasser on 12/16/25.
//

import Foundation

final class MockAIClient: AIClient {
    private var cancelled = false

    func cancelActiveRequest() {
        cancelled = true
    }

    func streamReply(to userText: String, toolResult: String?) -> AsyncThrowingStream<AIStreamEvent, Error> {
        cancelled = false

        return AsyncThrowingStream { continuation in
            Task {
                // If we just got a toolResult back, respond normally.
                if let toolResult {
                    let reply = "Done. \(toolResult)"
                    for ch in reply {
                        if self.cancelled { break }
                        continuation.yield(.textDelta(String(ch)))
                        try? await Task.sleep(nanoseconds: 10_000_000)
                    }
                    continuation.yield(.done)
                    continuation.finish()
                    return
                }

                // Decide whether to call save_memory (test heuristic)
                let lower = userText.lowercased()
                let seemsDurable =
                    lower.contains("every day") ||
                    lower.contains("nightly") ||
                    lower.contains("before bed") ||
                    lower.contains("tomorrow") ||
                    lower.contains("keep forgetting") ||
                    lower.contains("remember")

                if seemsDurable {
                    let args = """
                    {"text":"\(escapeJSON(userText))","tags":["habit","todo","memory"]}
                    """
                    continuation.yield(.toolCall(ToolCall(name: "save_memory", argumentsJSON: args)))
                    continuation.yield(.done)
                    continuation.finish()
                    return
                }

                // Otherwise just chat
                let reply = "Got it. You said: \(userText)"
                for ch in reply {
                    if self.cancelled { break }
                    continuation.yield(.textDelta(String(ch)))
                    try? await Task.sleep(nanoseconds: 10_000_000)
                }
                continuation.yield(.done)
                continuation.finish()
            }
        }
    }
    
    private func escapeJSON(_ s: String) -> String {
        s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
    }
}

