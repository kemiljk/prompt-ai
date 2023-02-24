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
    @State private var show_key_alert: Bool = false
    let key = "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"
    
    @FetchRequest(entity: APIUsesEntity.entity(), sortDescriptors: [])
    private var apiRequests: FetchedResults<APIUsesEntity>
        
    #if os(iOS)
    var device = UIDevice.current.userInterfaceIdiom
    let modal = UIImpactFeedbackGenerator(style: .medium)
    #endif

    
    var body: some View {
        NavigationStack {
            Form {
                Section("OpenAI API Key") {
                        VStack {
                            TextField("Enter OpenAI API Key", text: $SavedAPIKey.SavedAPIKey, axis: .vertical)
                                .font(.system(device == .phone ? .caption : .body, design: .monospaced))
                                .padding(.bottom, 16)
                                .padding(.vertical, device == .mac ? 8 : 0)
                            Button {
                                self.SavedAPIKey.SavedAPIKey = SavedAPIKey.SavedAPIKey
                                self.editMode?.wrappedValue = .inactive
                                self.isUpdated = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.isUpdated = false
                                }
                                if apiRequests.count >= 5 && SavedAPIKey.SavedAPIKey == key {
                                    self.show_key_alert = true
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
                .alert(isPresented: self.$show_key_alert) {
                    Alert(title: Text("You've used your free allowance"), message: Text("You only get 5 free questions before you'll need to add your own API key, tap the 'Get your API key' button to find out more."), dismissButton: .default(Text("Got it!")))
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if device == .phone {
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
