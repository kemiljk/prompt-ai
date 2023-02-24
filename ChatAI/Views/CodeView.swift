//
//  ContentView.swift
//  ChatAI
//
//  Created by Karl Koch on 14/12/2022.
//

import OpenAISwift
import SwiftUI
import CodeHighlighter

struct CodeView: View {
    @ObservedObject var aPIViewModel = APIViewModel()
    @ObservedObject var viewModel = CodeViewModel()
    @State private var promptText: String = ""
    @FocusState private var textFieldIsFocused: Bool
    @State private var show_settings_modal: Bool = false
    @State private var clear_all_messages: Bool = false
    @State private var query = ""
    @State private var show_alert: Bool = false
    #if os(iOS)
    private let h_screen = UIScreen.main.bounds.height
    var device = UIDevice.current.userInterfaceIdiom
    let modal = UIImpactFeedbackGenerator(style: .medium)
    #endif
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: CodeMessageEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CodeMessageEntity.timestamp, ascending: true)])
    private var messages: FetchedResults<CodeMessageEntity>
    @FetchRequest(entity: APIUsesEntity.entity(), sortDescriptors: [])
    private var apiRequests: FetchedResults<APIUsesEntity>
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if messages.isEmpty {
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
                        VStack(spacing: 12) {
                            VStack {
                                CodeTextView("final class isObserved: \nObservableObject {", language: "swift")
                            }
                            .padding(8)
                            .background(.thinMaterial)
                            .cornerRadius(8)
                            VStack {
                                CodeTextView("const node = nodes.map(async(newNode: String) => {", language: "javascript")
                            }
                            .padding(8)
                            .background(.thinMaterial)
                            .cornerRadius(8)
                            VStack {
                                CodeTextView("func incrementByOne() {", language: "swift")
                            }
                            .padding(8)
                            .background(.thinMaterial)
                            .cornerRadius(8)
                        }
                        .font(.system(.callout, design: .monospaced))
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
                                        CodeMessageView(message: message)
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
                        TextField("", text: $promptText, prompt: Text((apiRequests.count == 5 && aPIViewModel.SavedAPIKey == "") || (apiRequests.count >= 5 && aPIViewModel.SavedAPIKey == "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") || aPIViewModel.SavedAPIKey.isEmpty ? "Enter your API key" : "Ask me anything...").foregroundColor(.secondary).font(.system(.body, design: .monospaced)), axis: .vertical)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .monospaced))
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
                        } else {
                            Button {
                                submit()
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
            .navigationTitle("Code Prompt")
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
        }
    }
    
    private func submit() {
        viewModel.setup()
        
        withAnimation {
            guard !promptText.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            let promptMessage = CodeMessageEntity(context: viewContext)
            promptMessage.isPrompt = true
            promptMessage.text = promptText
            promptMessage.timestamp = Date()
            saveItems()
            viewModel.send(text: promptText) { gpt in
                self.promptText = ""
                let responseMessage = CodeMessageEntity(context: viewContext)
                responseMessage.isPrompt = false
                responseMessage.text = gpt.trimmingCharacters(in: .whitespacesAndNewlines)
                responseMessage.timestamp = Date()
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
       #keyPath(CodeMessageEntity.text), query)
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView()
    }
}
