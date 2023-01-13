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
    let codePersistenceController = CodePersistenceController.shared
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
                } else {
                    TabView {
                        Group {
                            TextView()
                                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                                .tabItem {
                                    Label("Text", systemImage: "text.bubble.fill")
                                }
                            CodeView()
                                .environment(\.managedObjectContext, codePersistenceController.container.viewContext)
                                .tabItem {
                                    Label("Code", systemImage: "terminal.fill")
                                }
                            ImageView()
                                .tabItem {
                                    Label("Image", systemImage: "photo.fill")
                                }
                        }
                        .environmentObject(SavedAPIKey)
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
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .tag(0)
            NavigationLink(destination: CodeView(), label: {
                Label("Code", systemImage: "terminal.fill")
            })
            .environment(\.managedObjectContext, codePersistenceController.container.viewContext)
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
    }
    
    var secondaryView: some View {
        TextView()
    }
}
