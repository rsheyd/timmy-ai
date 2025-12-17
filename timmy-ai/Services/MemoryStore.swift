//
//  MemoryStore.swift
//  timmy-ai
//
//  Created by Roman Sheydvasser on 12/17/25.
//

import Foundation

final class MemoryStore {
    struct Item: Codable, Equatable, Identifiable {
        let id: UUID
        let text: String
        let tags: [String]
        let createdAt: Date
    }

    private let url: URL
    private let queue = DispatchQueue(label: "timmy.memory.store")
    private var cache: [Item] = []

    init(filename: String = "memories.json") {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("Timmy", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        self.url = appDir.appendingPathComponent(filename)

        self.cache = (try? load()) ?? []
    }

    func save(text: String, tags: [String]) throws {
        try queue.sync {
            cache.insert(Item(id: UUID(), text: text, tags: tags, createdAt: Date()), at: 0)
            try persist()
        }
    }

    func all(limit: Int = 50) -> [Item] {
        queue.sync { Array(cache.prefix(limit)) }
    }

    private func load() throws -> [Item] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Item].self, from: data)
    }

    private func persist() throws {
        let data = try JSONEncoder().encode(cache)
        try data.write(to: url, options: [.atomic])
    }
}
