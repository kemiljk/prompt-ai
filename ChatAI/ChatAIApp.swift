//
//  ChatAIApp.swift
//  ChatAI
//
//  Created by Karl Koch on 14/12/2022.
//

import SwiftUI
import UIKit

@main
struct ChatAIApp: App {
    @StateObject var SavedAPIKey: APIViewModel = APIViewModel()
    let persistenceController = PersistenceController.shared
    var device = UIDevice.current.userInterfaceIdiom
    
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.mint)
    }
    
    var body: some Scene {
        WindowGroup {
            if device == .phone {
                if SavedAPIKey.SavedAPIKey.isEmpty {
                    InitView(key: SavedAPIKey.$SavedAPIKey)
                        .environmentObject(SavedAPIKey)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
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
                }
            } else {
                NavigationView {
                    sidebar
                    secondaryView
                }
            }
        }
    }
    
    var sidebar: some View {
        List {
            NavigationLink(destination: TextView(), label: {
                Label("Text", systemImage: "text.bubble.fill")
            })
            .tag(0)
            NavigationLink(destination: CodeView(), label: {
                Label("Code", systemImage: "terminal.fill")
            })
            .tag(1)
            NavigationLink(destination: ImageView(), label: {
                Label("Image", systemImage: "photo.fill")
            })
            .tag(2)
        }
        .navigationTitle("PromptAI")
        .tint(Color("DarkMint"))
        .listStyle(.sidebar)
        .environmentObject(SavedAPIKey)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
    
    var secondaryView: some View {
        TextView()
    }
}
