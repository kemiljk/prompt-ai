//
//  MessageView.swift
//  Prompt
//
//  Created by Karl Koch on 01/01/2023.
//

import SwiftUI
import CodeHighlighter

struct CodeMessageView: View {
    let message: CodeMessageEntity
    
    var body: some View {
        if message.isPrompt {
            HStack {
                Spacer()
                CodeTextView(message.text ?? "")
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
                CodeTextView(message.text ?? "")
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
