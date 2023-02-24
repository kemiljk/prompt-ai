//
//  InitView.swift
//  Prompt
//
//  Created by Karl Koch on 05/01/2023.
//

import SwiftUI

struct RequestsEmptyView: View {
    @ObservedObject var aPIViewModel = APIViewModel()
    @Binding var key: String
    private let h_screen = UIScreen.main.bounds.height
    @State private var openAPIModal: Bool = false
    @State private var show_settings_modal: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    let modal = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        VStack {
            Spacer()
                .frame(height: h_screen / 8)
            Text("You've run out of free requests")
                .font(.title)
            SpacerView(width: 0, height: 32)
            HStack {
                Text("Tap the ")
                Button {
                    self.show_settings_modal = true
                } label: {
                    Image(systemName: "gearshape")
                        .symbolVariant(.fill)
                        .foregroundColor(.mint)
                }
                Text("to get add your own API key")
            }
            SpacerView(width: 0, height: 32)
            Button("Get your API key") {
                self.openAPIModal = true
                self.modal.impactOccurred()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .foregroundColor(colorScheme == .dark ? .black : nil)
            .sheet(isPresented: $openAPIModal) {
                APILinkView()
                    .presentationDetents([.medium, .large])
            }
            Group {
                SpacerView(width: 0, height: 32)
                Text("PromptAI allows you to chat directly with the GPT-3 AI model, enabling you to ask questions in text format, request code completion or generate a DALL-E-powered image.")
                SpacerView(width: 0, height: 16)
                Text("OpenAI is in active beta, and some requests can take a while to receive an answer. Please be patient.")
            }
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        Spacer()
        .sheet(isPresented: self.$show_settings_modal) {
            SettingsView()
                .presentationDetents([.fraction(0.35), .medium])
                .onDisappear {
                    self.key = aPIViewModel.SavedAPIKey
                }
            
        }
    }
}
