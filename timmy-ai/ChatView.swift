import SwiftUI

struct ChatView: View {
    @ObservedObject var context: ContextModel
    @State private var input = ""
    @State private var messages: [String] = ["Hi, I’m Timmy. What should we focus on?"]
    let aiClient: AIClient = MockAIClient()

    var body: some View {
        VStack(spacing: 8) {
            // Optional: show current context at the top (dev-friendly)
            if let snapshot = context.snapshot {
                Text(snapshot.asContextBlock(maxWindows: 10, maxCounts: 6))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .lineLimit(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages.indices, id: \ .self) { idx in
                        Text(messages[idx])
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type to Timmy…", text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(send)
                Button("Send", action: send)
                    .keyboardShortcut(.return, modifiers: [.command])
            }
            .padding([.horizontal, .bottom])
        }
        .frame(width: 420, height: 520)
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append("You: \(text)")
        input = ""

        // If it’s a local command, handle it and stop
        if handleCommand(text) { return }

        // placeholder assistant message we’ll stream into
        messages.append("Timmy: ")
        let assistantIndex = messages.count - 1

        Task { @MainActor in
            let toolRouter = ToolRouter(contextModel: context, memoryStore: MemoryStore())

            @MainActor
            func streamOnce(toolResult: String?) async throws {
                var buffer = messages[assistantIndex]

                for try await event in aiClient.streamReply(to: text, toolResult: toolResult) {
                    switch event {
                    case .textDelta(let d):
                        buffer += d
                        messages[assistantIndex] = buffer

                    case .toolCall(let call):
                        let result = toolRouter.run(call)
                        messages.append("— tool \(call.name) → \(result)")
                        try await streamOnce(toolResult: result)
                        return

                    case .done:
                        return
                    }
                }
            }

            do {
                try await streamOnce(toolResult: nil)
            } catch {
                messages[assistantIndex] = "Timmy: (error) \(error.localizedDescription)"
            }
        }
    }


    private func handleCommand(_ text: String) -> Bool {
        let lower = text.lowercased()
        
        if lower == "memories" || lower.contains("show memories") {
            let store = MemoryStore()
            let items = store.all(limit: 10)

            if items.isEmpty {
                messages.append("Timmy: No memories saved yet.")
            } else {
                var text = "Timmy: Recent memories:\n"
                for m in items {
                    let tags = m.tags.isEmpty ? "" : " [\(m.tags.joined(separator: ", "))]"
                    text += "• \(m.text)\(tags)\n"
                }
                messages.append(text)
            }
            return true
        }
        
        if lower == "context" || lower.contains("show context") {
            if let snapshot = context.snapshot {
                        messages.append("Timmy:\n" + snapshot.asContextBlock(maxWindows: 25, maxCounts: 10))
                    } else {
                        messages.append("Timmy: No context snapshot yet (try toggling the chat again).")
                    }
                    return true
                }

        // Command: count number of windows open
        if lower.contains("count windows") || lower.contains("how many windows") {
            let n = context.snapshot?.topWindows.count ?? 0
                    messages.append("Timmy: I see \(n) window(s) in the current snapshot.")
                    return true
                }

        return false
    }
}

#Preview {
    ChatView(context: ContextModel())
}

