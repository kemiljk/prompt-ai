//
//  ContentView.swift
//  ChatAI
//
//  Created by Karl Koch on 14/12/2022.
//

import SwiftUI
import OpenAISwift
import CoreData
import WidgetKit

struct TextView: View {
    @AppStorage("result", store: UserDefaults(suiteName: "group.com.kejk.promptai")) var result: String = ""
    @ObservedObject var aPIViewModel = APIViewModel()
    @ObservedObject var viewModel = TextViewModel()
    @State private var promptText: String = ""
    @FocusState private var textFieldIsFocused: Bool
    @State private var show_settings_modal: Bool = false
    @State private var clear_all_messages: Bool = false
    @State private var openAPIModal: Bool = false
    @State private var query = ""
    @State private var show_alert: Bool = false
    #if os(iOS)
    private let h_screen = UIScreen.main.bounds.height
    var device = UIDevice.current.userInterfaceIdiom
    let modal = UIImpactFeedbackGenerator(style: .medium)
    #endif
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: MessageEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \MessageEntity.timestamp, ascending: true)])
    private var messages: FetchedResults<MessageEntity>
    @FetchRequest(entity: APIUsesEntity.entity(), sortDescriptors: [])
    private var apiRequests: FetchedResults<APIUsesEntity>

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if messages.isEmpty && !APIViewModel().SavedAPIKey.isEmpty {
                    VStack {
                        #if os(iOS)
                        Spacer()
                            .frame(height: h_screen / 8)
                        #else
                        Spacer()
                            .frame(height: 80)
                        #endif
                        Text("Send your first prompt to get started.")
                            .font(.headline.bold())
                        SpacerView(width: 0, height: 32)
                        Label("Why not try", systemImage: "info.circle")
                            .foregroundColor(.primary)
                        SpacerView(width: 0, height: 16)
                        Group {
                            Text("'Write the first paragraph of a crime novel'")
                                .font(.system(.callout, design: .monospaced))
                            SpacerView(width: 0, height: 12)
                            Text("'How many animals would fit inside Wembley Stadium?'")
                                .font(.system(.callout, design: .monospaced))
                            SpacerView(width: 0, height: 12)
                            Text("'Write Pi to 1000 decimal places'")
                                .font(.system(.callout, design: .monospaced))
                        }
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                } else {
                    VStack(alignment: .leading) {
                        ScrollViewReader { scrollView in
                            VStack(alignment: .leading, spacing: 8) {
                                ScrollView {
                                    ForEach(messages, id: \.self) { message in
                                        MessageView(message: message)
                                            .id(message.objectID)
                                    }
                                    .padding([.top, .horizontal])
                                    if viewModel.isLoading {
                                        ThinkingView()
                                            .padding([.top, .horizontal])
                                    }
                                }
                            }
                            .onChange(of: messages.count) { _ in
                                if let last = messages.last {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.easeOut) {
                                            if !messages.isEmpty {
                                                scrollView.scrollTo(last.objectID, anchor: .top)
                                            }
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                if let last = messages.last {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.easeOut) {
                                            if !messages.isEmpty {
                                                scrollView.scrollTo(last.objectID, anchor: .bottom)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
                VStack {
                    HStack {
                        TextField("", text: $promptText, prompt: Text((apiRequests.count == 5 && aPIViewModel.SavedAPIKey == "") || (apiRequests.count >= 5 && aPIViewModel.SavedAPIKey == "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") || aPIViewModel.SavedAPIKey.isEmpty ? "Enter your API key" : "Ask me anything...").foregroundColor(.secondary), axis: .vertical)
                            .focused($textFieldIsFocused)
                            .disabled((apiRequests.count == 5 && aPIViewModel.SavedAPIKey == "") || (apiRequests.count >= 5 && aPIViewModel.SavedAPIKey == "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"))
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button {
                                        self.hideKeyboard()
                                    } label: {
                                        Image(systemName: "keyboard.chevron.compact.down")
                                    }
                                }
                            }
                        if (viewModel.isLoading && !viewModel.error) {
                            ProgressView()
                                .padding(.leading, 4)
                                .padding(.vertical, 12)
                        } else {
                            Button {
                                viewModel.setup()
                                submit()
                                print(APIViewModel().SavedAPIKey)
                                incrementRequest()
                                self.hideKeyboard()
                                if apiRequests.count == 5 && aPIViewModel.SavedAPIKey == "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" {
                                    self.show_alert = true
                                }
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                            }
                            .keyboardShortcut(.defaultAction)
                            .disabled(APIViewModel().SavedAPIKey.isEmpty || promptText.isEmpty || (apiRequests.count == 5 && aPIViewModel.SavedAPIKey == "") || (apiRequests.count >= 5 && aPIViewModel.SavedAPIKey == "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"))
                            .buttonStyle(MacButtonStyle())
                        }
                    }
                    .padding(.top, device == .phone ? 8 : 0)
                }
                .padding(device == .phone || device == .pad ? 12 : 8)
                .padding(.leading, device == .pad || device == .mac ? 4 : 0)
                .background(Color("Grey"))
                .cornerRadius(32, corners: device == .phone ? [.topLeft, .topRight] : [.allCorners])
                .padding(.vertical, device == .phone ? 0 : 24)
                .padding(.horizontal, device == .phone ? 0 : 16)
            }
            .searchable(text: $query)
            .onChange(of: query) { newValue in
              messages.nsPredicate = searchPredicate(query: newValue)
            }
            .alert(isPresented: $show_alert) {
                Alert(title: Text("Enter your API key"), message: Text("You'll need to enter your personal API key to ask more prompts"))
            }
            .navigationTitle("Text Prompt")
            .navigationBarTitleDisplayMode(device == .phone ? .inline : .automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.clear_all_messages = true
                        self.modal.impactOccurred()
                    } label: {
                        Image(systemName: "eraser.line.dashed")
                            .symbolVariant(.fill)
                    }
                    .buttonStyle(.borderless)
                    .disabled(messages.isEmpty)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if device == .phone {
                    Button {
                        self.show_settings_modal = true
                        self.modal.impactOccurred()
                    } label: {
                        Image(systemName: "gearshape")
                            .symbolVariant(.fill)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: self.$show_settings_modal) {
            SettingsView()
                .presentationDetents([.fraction(0.35), .medium])
            
        }
        .alert(isPresented: self.$viewModel.error) {
            Alert(title: Text("We couldn't send your request"), message: Text("Try again later or double check your API key is still active"), dismissButton: .default(Text("Got it!")))
        }
        .alert(isPresented: self.$clear_all_messages) {
            Alert(title: Text("Are you sure?"), message: Text("This will remove all the messages from your device"), primaryButton: .destructive(Text("Delete all")) {deleteAllItems()}, secondaryButton: .default(Text("Cancel")))
        }
        .onAppear {
            viewModel.setup()
            if !messages.isEmpty {
                self.result = messages.last!.text ?? result
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func submit() {
        viewModel.setup()
        
        withAnimation {
            guard !promptText.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            let promptMessage = MessageEntity(context: viewContext)
            promptMessage.isPrompt = true
            promptMessage.text = promptText
            promptMessage.timestamp = Date()
            saveItems()
            viewModel.send(text: promptText) { gpt in
                self.promptText = ""
                let responseMessage = MessageEntity(context: viewContext)
                responseMessage.isPrompt = false
                responseMessage.text = gpt.trimmingCharacters(in: .whitespacesAndNewlines)
                responseMessage.timestamp = Date()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.result = responseMessage.text!
                    WidgetCenter.shared.reloadAllTimelines()
                }
                saveItems()
            }
        }
    }
    
    private func incrementRequest() {
        let increment = APIUsesEntity(context: viewContext)
        let key = "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"
        if apiRequests.count < 5 {
            increment.requests += 1
            saveItems()
        }
        if apiRequests.count >= 5 && aPIViewModel.SavedAPIKey == key {
            UserDefaults.standard.set("", forKey: "savedAPIKey")
        }
        print(apiRequests.count)
    }
    
    private func saveItems() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            print(error)
        }
    }
    
    private func deleteAllItems() {
        messages.forEach { item in
            viewContext.delete(item)
        }
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    private func searchPredicate(query: String) -> NSPredicate? {
      if query.isEmpty { return nil }
        return NSPredicate(format: "%K CONTAINS[cd] %@",
        #keyPath(MessageEntity.text), query)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TextView()
    }
}
