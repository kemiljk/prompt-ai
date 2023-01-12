//
//  MessageView.swift
//  Prompt
//
//  Created by Karl Koch on 01/01/2023.
//

import SwiftUI
import CodeHighlighter

struct CodeMessage: Equatable {
    let codeMessageId = UUID().uuidString
    let codeMessageText: String
    let isPrompt: Bool
}

struct CodeMessageView: View {
    let message: Message
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if message.isPrompt {
            HStack {
                Spacer()
                CodeTextView(message.messageText ?? "")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color("AccentColor").opacity(0.1))
                    .cornerRadius(24)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity)
        } else {
            HStack {
                CodeTextView(message.messageText ?? "")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(24)
                    .textSelection(.enabled)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
