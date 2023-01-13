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
    @ObservedObject var viewModel = CodeViewModel()
    @State private var promptText: String = ""
    @FocusState private var textFieldIsFocused: Bool
    @State private var show_settings_modal: Bool = false
    @State private var clear_all_messages: Bool = false
    private let h_screen = UIScreen.main.bounds.height
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: CodeMessageEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CodeMessageEntity.timestamp, ascending: true)])
    private var messages: FetchedResults<CodeMessageEntity>
    let modal = UIImpactFeedbackGenerator(style: .medium)
    var device = UIDevice.current.userInterfaceIdiom
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if messages.isEmpty {
                    VStack {
                        Spacer()
                            .frame(height: h_screen / 8)
                        Text("Send your first prompt to get started")
                            .font(.headline.bold())
                        SpacerView(width: 0, height: 32)
                        Label("Why not try", systemImage: "info.circle")
                            .foregroundColor(.primary)
                        SpacerView(width: 0, height: 16)
                        VStack(spacing: 12) {
                            VStack {
                                CodeTextView("final class isObserved: \nObservableObject {")
                            }
                            .padding(8)
                            .background(.thinMaterial)
                            .cornerRadius(8)
                            VStack {
                                CodeTextView("const node = nodes.map( async (newNode: String) => {", language: "javascript")
                            }
                            .padding(8)
                            .background(.thinMaterial)
                            .cornerRadius(8)
                            VStack {
                                CodeTextView("func incrementByOne() {")
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
                        TextField("", text: $promptText, prompt: Text("Ask me anything...").foregroundColor(.secondary).font(.system(.body, design: .monospaced)), axis: .vertical)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .monospaced))
                            .focused($textFieldIsFocused)
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
                                self.hideKeyboard()
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                            }
                            .disabled(APIViewModel().SavedAPIKey.isEmpty || promptText.isEmpty)
                        }
                    }
                    .padding(.top, device == .phone ? 8 : 0)
                }
                .padding()
                .background(Color("Grey"))
                .cornerRadius(32, corners: device == .phone ? [.topLeft, .topRight] : [.allCorners])
                .padding(device == .phone ? 0 : 24)
            }
            .navigationTitle("Code Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
//                leading:
//                    Button {
//                        // MARK: Fix this!
//                        self.clear_all_messages = true
//                        self.modal.impactOccurred()
//                    } label: {
//                        Image(systemName: "eraser.line.dashed")
//                            .symbolVariant(.fill)
//                    }
//                    .disabled(messages.isEmpty)
//                ,
                trailing:
                    Button {
                        self.show_settings_modal = true
                        self.modal.impactOccurred()
                    } label: {
                        Image(systemName: "gearshape")
                            .symbolVariant(.fill)
                    }
            )
        }
        .sheet(isPresented: self.$show_settings_modal) {
            SettingsView()
                .presentationDetents([.fraction(0.35), .medium])
        }
        .alert(isPresented: self.$viewModel.error) {
            Alert(title: Text("We couldn't send your request"), message: Text("Try again later or double check your API key is still active"), dismissButton: .default(Text("Got it!")))
        }
        .alert(isPresented: self.$clear_all_messages) {
            Alert(title: Text("Erased!"), message: Text("All messages are now cleared"), dismissButton: .default(Text("Got it!")))
        }
        .onAppear {
            viewModel.setup()
        }
    }
    
    private func submit() {
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
                if(gpt.hasPrefix("\n\n")) {
                    let index = gpt.index(gpt.startIndex, offsetBy: 2)
                    let output = String(gpt[index...])
                    let responseMessage = CodeMessageEntity(context: viewContext)
                    responseMessage.isPrompt = false
                    responseMessage.text = output
                    responseMessage.timestamp = Date()
                    saveItems()
                } else {
                    let responseMessage = CodeMessageEntity(context: viewContext)
                    responseMessage.isPrompt = false
                    responseMessage.text = gpt
                    responseMessage.timestamp = Date()
                    saveItems()
                }
            }
        }
    }
    
    private func saveItems() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            print(error)
        }
    }
    
    private func removeMessages(offsets: IndexSet) {
        for index in offsets {
            let message = messages[index]
            viewContext.delete(message)
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView()
    }
}
