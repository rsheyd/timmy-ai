//
//  AIClient.swift
//  timmy-ai
//
//  Created by Roman Sheydvasser on 12/16/25.
//

import Foundation

struct ToolCall {
    let name: String
    let argumentsJSON: String
}

enum AIStreamEvent {
    case textDelta(String)
    case toolCall(ToolCall)
    case done
}

protocol AIClient {
    func streamReply(to userText: String, toolResult: String?) -> AsyncThrowingStream<AIStreamEvent, Error>
    func cancelActiveRequest()
}

