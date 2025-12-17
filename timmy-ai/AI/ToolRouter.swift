//
//  ToolRouter.swift
//  timmy-ai
//
//  Created by Roman Sheydvasser on 12/16/25.
//

import Foundation

final class ToolRouter {
    private let contextModel: ContextModel
    private let memoryStore: MemoryStore

    init(contextModel: ContextModel, memoryStore: MemoryStore) {
           self.contextModel = contextModel
           self.memoryStore = memoryStore
    }

    func run(_ call: ToolCall) -> String {
        switch call.name {
        case "get_context_snapshot":
            return contextModel.snapshot?.asContextBlock() ?? "No context snapshot available."
            
        case "save_memory":
            // args: {"text":"...", "tags":["...","..."]}
            do {
                let args = try decode(SaveMemoryArgs.self, call.argumentsJSON)
                try memoryStore.save(text: args.text, tags: args.tags ?? [])
                return "Saved memory."
            } catch {
                return "Failed to save memory: \(error.localizedDescription)"
            }

        default:
            return "Unknown tool: \(call.name)"
        }
    }
    
    private struct SaveMemoryArgs: Codable {
            let text: String
            let tags: [String]?
        }

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }
}
