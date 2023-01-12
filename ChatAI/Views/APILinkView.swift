//
//  APILinkView.swift
//  Prompt
//
//  Created by Karl Koch on 03/01/2023.
//

import SwiftUI

struct APILinkView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .foregroundColor(Color("AccentColor"))
                            .padding(.leading, 4)
                            .padding(.trailing, 12)
                        Link("Visit OpenAI", destination: URL(string: "https://beta.openai.com/login")!)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.secondary.opacity(0.75))
                    }
                    Label("Click on your profile photo", systemImage: "2.circle.fill")
                    Label("Choose 'View API Keys'", systemImage: "3.circle.fill")
                    Label("Tap 'Create new secret key'", systemImage: "4.circle.fill")
                    Label("Copy the new key, enter it in the OPENAI input", systemImage: "5.circle.fill")
                }
                .multilineTextAlignment(.leading)
            }
            .navigationTitle("Get your API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        self.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .symbolVariant(.fill)
                            .tint(.secondary)
                    }
                }
            }
        }
    }
}

struct APILinkView_Previews: PreviewProvider {
    static var previews: some View {
        APILinkView()
    }
}
