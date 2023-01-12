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
//    @State private var messages: [Message] = []
    @FocusState private var textFieldIsFocused: Bool
    @State private var show_settings_modal: Bool = false
    @State private var clear_all_messages: Bool = false
    private let h_screen = UIScreen.main.bounds.height
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Message.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Message.messageId, ascending: false)])
    var messages: FetchedResults<Message>
    
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
                        ScrollView {
                            ScrollViewReader { scrollView in
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(messages, id: \.messageId) { message in
                                        CodeMessageView(message: message)
                                    }
                                    if viewModel.isLoading {
                                        ThinkingView()
                                    }
                                }
                                .padding([.top, .horizontal])
//                                .onChange(of: messages, perform: { value in
//                                    DispatchQueue.main.async {
//                                        withAnimation(.easeOut) {
//                                            if !messages.isEmpty {
//                                                scrollView.scrollTo(messages[messages.endIndex - 1].messageId, anchor: .top)
//                                            }
//                                        }
//                                    }
//                                })
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
                leading:
                    Button {
//                        messages = []
                        self.clear_all_messages = true
                        self.modal.impactOccurred()
                    } label: {
                        Image(systemName: "eraser.line.dashed")
                            .symbolVariant(.fill)
                    }
                    .disabled(messages.isEmpty)
                ,
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
    
    func submit() {
        guard !promptText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
//        let message = Message(messageText: promptText, isPrompt: true)
//        messages.append(message)
        viewModel.send(text: promptText) { gpt in
            self.promptText = ""
//            let response = Message(messageText: gpt, isPrompt: false)
            DispatchQueue.main.async {
//                messages.append(response)
            }
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView()
    }
}
