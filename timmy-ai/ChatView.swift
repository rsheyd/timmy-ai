import SwiftUI

struct ChatView: View {
    @ObservedObject var context: ContextModel
    @State private var input = ""
    @State private var messages: [String] = ["Hi, I’m Timmy. What should we focus on?"]

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
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let user = "You: \(input)"
        messages.append(user)

        // Try to handle as a command. If handled, don't append the placeholder.
        if handleCommand(trimmed) {
            input = ""
            return
        }

        // Default placeholder response for non-command messages.
        messages.append("Timmy: Got it. I’ll help you with that next.")
        input = ""
    }

    private func handleCommand(_ text: String) -> Bool {
        let lower = text.lowercased()
        
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

