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
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let user = "You: \(input)"
        messages.append(user)
        // Placeholder response:
        messages.append("Timmy: Got it. I’ll help you with that next.")
        input = ""
    }
}

#Preview {
    ChatView()
}
