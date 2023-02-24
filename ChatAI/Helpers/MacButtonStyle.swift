//
//  MacButtonStyle.swift
//  Prompt
//
//  Created by Karl Koch on 22/01/2023.
//

import SwiftUI

struct MacButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(8)
            .clipShape(Circle())
            .foregroundColor(.mint)
            .cornerRadius(8)
    }
}

