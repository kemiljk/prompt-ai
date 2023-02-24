//
//  ChatAIApp.swift
//  ChatAI
//
//  Created by Karl Koch on 14/12/2022.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
import WidgetKit

@main
struct ChatAIApp: App {
    @StateObject var SavedAPIKey: APIViewModel = APIViewModel()
    @ObservedObject var viewModel = TextViewModel()
    let persistenceController = PersistenceController.shared
    #if os(iOS)
    var device = UIDevice.current.userInterfaceIdiom
    #endif
    
    #if os(iOS)
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.mint)
        let SavedAPIKey = APIViewModel()
            self._SavedAPIKey = StateObject(wrappedValue: SavedAPIKey)
    }
    #endif
    
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            if device == .phone {
                if SavedAPIKey.SavedAPIKey.isEmpty {
                    InitView(key: SavedAPIKey.$SavedAPIKey)
                        .environmentObject(SavedAPIKey)
                }
//                else if SavedAPIKey.apiRequests.count == 5 {
//                    RequestsEmptyView(key: SavedAPIKey.$SavedAPIKey)
//                        .environmentObject(SavedAPIKey)
//                }
                else {
                    TabView {
                        Group {
                            TextView()
                                .tabItem {
                                    Label("Text", systemImage: "text.bubble.fill")
                                }
                            CodeView()
                                .tabItem {
                                    Label("Code", systemImage: "terminal.fill")
                                }
                            ImageView()
                                .tabItem {
                                    Label("Image", systemImage: "photo.fill")
                                }
                        }
                        .environmentObject(SavedAPIKey)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .toolbarBackground(.visible, for: .tabBar)
                        .toolbarBackground(Color("Grey"), for: .tabBar)
                    }
                    .onAppear {
                        viewModel.setup()
                        DispatchQueue.main.async {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                }
            }
            #endif
            if device == .pad || device == .mac {
                NavigationSplitView {
                    sidebar
                        .navigationSplitViewColumnWidth(
                                    min: 150, ideal: 200, max: 400)
                    } detail: {
                        if SavedAPIKey.SavedAPIKey.isEmpty {
                            InitView(key: SavedAPIKey.$SavedAPIKey)
                        }
//                        else if SavedAPIKey.apiRequests.count == 5 {
//                            RequestsEmptyView(key: SavedAPIKey.$SavedAPIKey)
//                                .environmentObject(SavedAPIKey)
//                        }
                        else {
                            secondaryView
                                .environmentObject(SavedAPIKey)
                        }
                }
                .environmentObject(SavedAPIKey)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    viewModel.setup()
                    DispatchQueue.main.async {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
        }
    }
        
    var sidebar: some View {
        List {
            NavigationLink(destination: TextView(), label: {
                Label("Text", systemImage: "text.bubble.fill")
                    .tag(0)
            })
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            NavigationLink(destination: CodeView(), label: {
                Label("Code", systemImage: "terminal.fill")
                    .tag(1)
            })
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            NavigationLink(destination: ImageView(), label: {
                Label("Image", systemImage: "photo.fill")
                    .tag(2)
            })
            Divider()
            NavigationLink(destination: SettingsView(), label: {
                Label("Settings", systemImage: "gearshape.fill")
                    .tag(3)
            })
        }
        .navigationTitle("PromptAI")
        .tint(Color("DarkMint"))
        .listStyle(SidebarListStyle())
        .environmentObject(SavedAPIKey)
    }
    
    var secondaryView: some View {
        TextView()
            .tag(0)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}
