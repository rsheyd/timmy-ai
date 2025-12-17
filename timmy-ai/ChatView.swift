import SwiftUI

struct ChatView: View {
    @State private var input = ""
    @State private var messages: [String] = ["Hi, I’m Timmy. What should we focus on?"]

    var body: some View {
        VStack(spacing: 8) {
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

        // Command: explicitly prompt for Accessibility permission (no-op now)
        if lower.contains("grant accessibility") || lower == "grant" {
            messages.append("Timmy: I no longer need Accessibility permission. Window counting has been removed.")
            return true
        }

        // Command: count windows across all apps (removed)
        if lower.contains("count windows") || lower.contains("how many windows") {
            messages.append("Timmy: I don't count windows anymore. If you need this back, let me know and I can re-enable it.")
            return true
        }

        return false
    }
}

#Preview {
    ChatView()
}

