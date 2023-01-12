//
//  SettingsView.swift
//  Prompt
//
//  Created by Karl Koch on 31/12/2022.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var SavedAPIKey = APIViewModel()
    @ObservedObject var textViewModel = TextViewModel()
    @ObservedObject var codeViewModel = CodeViewModel()
    @ObservedObject var imageViewModel = ImageViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @Environment(\.colorScheme) private var colorScheme
    @State private var openAPIModal: Bool = false
    @State private var isUpdated: Bool = false
    
    let modal = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationStack {
            Form {
                Section("OpenAI API Key") {
                        VStack {
                            TextField("Enter OpenAI API Key", text: $SavedAPIKey.SavedAPIKey, axis: .vertical)
                                .font(.system(.caption, design: .monospaced))
                                .padding(.bottom, 16)
                            Button {
                                self.SavedAPIKey.SavedAPIKey = SavedAPIKey.SavedAPIKey
                                self.editMode?.wrappedValue = .inactive
                                self.isUpdated = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.isUpdated = false
                                }
                            } label: {
                                Text(isUpdated == false ? "Save" : isUpdated == true ? "Updated" : "Update")
                                    .foregroundColor(colorScheme == .light ? .white : .black)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(colorScheme == .light ? .black : .white)
                        }
                }
                Button("Get your API key") {
                    self.openAPIModal = true
                    self.modal.impactOccurred()
                }
                .sheet(isPresented: $openAPIModal) {
                    APILinkView()
                        .presentationDetents([.medium, .large])
                }
            }
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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                self.textViewModel.updateKey()
                self.codeViewModel.updateKey()
                self.imageViewModel.updateKey()
            }
        }
    }
    
    func saveAPIKey(API: String) {
        SavedAPIKey.SavedAPIKey = API
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
