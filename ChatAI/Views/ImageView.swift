//
//  ImageView.swift
//  ChatAI
//
//  Created by Karl Koch on 14/12/2022.
//

import OpenAIKit
import SwiftUI



struct ImageView: View {
    class SheetMananger: ObservableObject{
        @Published var isSharePresented = false
        @Published var activityItems: [Any] = []
    }
    
    
    @StateObject var sheetManager = SheetMananger()
    @ObservedObject var imageViewModel = ImageViewModel()
    @State var text: String = ""
    @State var image: UIImage?
    @State var promptText: String = ""
    @State private var show_settings_modal: Bool = false
    @State private var refresh_text: String = ""
    @FocusState private var textFieldIsFocused: Bool
    private let h_screen = UIScreen.main.bounds.height
    
    @Environment(\.colorScheme) private var colorScheme
    
    let save = UIImpactFeedbackGenerator(style: .medium)
    let modal = UIImpactFeedbackGenerator(style: .medium)
    
    #if os(iOS)
        var device = UIDevice.current.userInterfaceIdiom
    var portrait = UIDeviceOrientation.portrait.isPortrait
    #endif
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                    ScrollView {
                        VStack {
                            if image == nil && !imageViewModel.isLoading {
                                VStack {
                                    Spacer()
                                        .frame(height: h_screen / 8)
                                    Text("Send your first prompt to get started")
                                        .font(.headline.bold())
                                    SpacerView(width: 0, height: 32)
                                    Label("Why not try", systemImage: "info.circle")
                                        .foregroundColor(.primary)
                                    SpacerView(width: 0, height: 16)
                                    Group {
                                        Text("'A cat, in a hat, on a mat, photorealistic'")
                                            .font(.system(.callout, design: .monospaced))
                                        SpacerView(width: 0, height: 12)
                                        Text("'A portait of Prince William in the style of Van Gogh'")
                                            .font(.system(.callout, design: .monospaced))
                                        SpacerView(width: 0, height: 12)
                                        Text("'A fantasy picture of a large rock-like structure on a deserted island'")
                                            .font(.system(.callout, design: .monospaced))
                                    }
                                    .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            } else if (imageViewModel.isLoading) {
                                Spacer()
                                HStack(alignment: .top) {
                                    Text("Prompt: ")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.secondary)
                                    Text(promptText)
                                        .font(.system(.body, design: .default))
                                        .foregroundColor(.primary)
                                }
                                .frame(width: device == .phone ? UIScreen.main.bounds.width - 32 : UIScreen.main.bounds.height / 1.5)
                                    if device == .phone {
                                        ZStack {
                                            Rectangle()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width - 32)
                                                .foregroundStyle(.thinMaterial)
                                                .cornerRadius(16)
                                            ProgressView()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.primary)
                                        }
                                    } else {
                                        VStack {
                                            ZStack {
                                                Rectangle()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: UIScreen.main.bounds.height / 2, height: UIScreen.main.bounds.height / 2)
                                                    .foregroundStyle(.thinMaterial)
                                                    .cornerRadius(16)
                                                ProgressView()
                                                    .frame(width: 24, height: 24)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                }
                            } else {
                                if let image = image {
                                    Spacer()
                                        HStack(alignment: .top) {
                                            Text("Prompt: ")
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundColor(.secondary)
                                            Text(promptText)
                                                .font(.system(.body, design: .default))
                                                .foregroundColor(.primary)
                                        }
                                        .frame(width: device == .phone ? UIScreen.main.bounds.width - 32 : UIScreen.main.bounds.height / 1.5)
                                    if device == .phone {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width:  UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width - 32)
                                            .cornerRadius(16)
                                            .onLongPressGesture {
                                                sheetManager.activityItems.removeAll()
                                                sheetManager.activityItems.append(image)
                                                self.sheetManager.isSharePresented = true
                                                if device == .phone {
                                                    self.save.impactOccurred()
                                                }
                                            }
                                            .sheet(isPresented: $sheetManager.isSharePresented, content: {
                                                ActivityViewController(activityItems: sheetManager.activityItems)
#if os(iOS)
                                                    .presentationDetents([.medium, .large])
#endif
                                            })
                                    } else {
                                        VStack {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: UIScreen.main.bounds.height / 2, height: UIScreen.main.bounds.height / 2)
                                                .cornerRadius(16)
                                                .onLongPressGesture {
                                                    sheetManager.activityItems.removeAll()
                                                    sheetManager.activityItems.append(image)
                                                    self.sheetManager.isSharePresented = true
                                                    if device == .phone {
                                                        self.save.impactOccurred()
                                                    }
                                                }
                                                .sheet(isPresented: $sheetManager.isSharePresented, content: {
                                                    ActivityViewController(activityItems: sheetManager.activityItems)
#if os(iOS)
                                                        .presentationDetents([.medium, .large])
#endif
                                                })
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    SpacerView(width: 0, height: 16)
                                    HStack {
                                        Button {
                                            sheetManager.activityItems.removeAll()
                                            sheetManager.activityItems.append(image)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                self.sheetManager.isSharePresented = true
                                            }
                                            if device == .phone {
                                                self.save.impactOccurred()
                                            }
                                        } label: {
                                            Label("Save", systemImage: "square.and.arrow.down")
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .controlSize(.regular)
                                        .foregroundColor(colorScheme == .dark ? .black : nil)
                                        Button {
                                            self.promptText = refresh_text
                                            Task {
                                                let result = await imageViewModel.generateImage(prompt: refresh_text)
                                                if result == nil {
                                                    print("Could not load an image")
                                                } else {
                                                    self.image = result
                                                }
                                            }
                                            self.hideKeyboard()
                                        } label: {
                                            Label("Refresh", systemImage: "arrow.clockwise")
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.regular)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                    VStack {
                        HStack {
                            TextField("", text: $text, prompt: Text("Enter an image request...").foregroundColor(.secondary), axis: .vertical)
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
                            if (imageViewModel.isLoading && !imageViewModel.error) {
                                ProgressView()
                                    .padding(.leading, 4)
                            } else {
                                Button {
                                    self.promptText = text
                                    self.refresh_text = text
                                    Task {
                                        let result = await imageViewModel.generateImage(prompt: text)
                                        self.text = ""
                                        if result == nil {
                                            print("Could not load an image")
                                        } else {
                                            self.image = result
                                        }
                                    }
                                    self.hideKeyboard()
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                }
                                .disabled(APIViewModel().SavedAPIKey.isEmpty || text.isEmpty)
                            }
                        }
                        .padding(.top, device == .phone ? 8 : 0)
                    }
                    .padding()
                    .background(Color("Grey"))
                    .cornerRadius(32, corners: device == .phone ? [.topLeft, .topRight] : [.allCorners])
                    .padding(device == .phone ? 0 : 24)
            }
            .navigationTitle("Image Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
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
        .alert(isPresented: self.$imageViewModel.error) {
            Alert(title: Text("We couldn't send your request"), message: Text("Try again later or double check your API key is still active"), dismissButton: .default(Text("Got it!")))
        }
        .onAppear {
            imageViewModel.setup()
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
