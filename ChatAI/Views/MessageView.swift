//
//  MessageView.swift
//  Prompt
//
//  Created by Karl Koch on 01/01/2023.
//

import SwiftUI

struct MessageView: View {
    let message: MessageEntity
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if message.isPrompt {
            HStack {
                Spacer()
                Text(message.text ?? "")
                    .foregroundColor(colorScheme == .light ? .white : .black)
                    .padding()
                    .background(.tint)
                    .cornerRadius(24)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity)
        } else {
            HStack {
                Text(message.text ?? "")
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
