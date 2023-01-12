//
//  MessageView.swift
//  Prompt
//
//  Created by Karl Koch on 01/01/2023.
//

import SwiftUI

//struct Message: Equatable {
//    let messageId = UUID().uuidString
//    let messageText: String
//    let isPrompt: Bool
//}

struct MessageView: View {
    let message: Message
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if message.isPrompt {
            HStack {
                Spacer()
                Text(message.messageText ?? "")
                    .foregroundColor(colorScheme == .light ? .white : .black)
                    .padding()
                    .background(.tint)
                    .cornerRadius(24)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity)
        } else {
            HStack {
                Text(message.messageText ?? "")
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
