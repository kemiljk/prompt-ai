//
//  APIViewModel.swift
//  Prompt
//
//  Created by Karl Koch on 03/01/2023.
//

import SwiftUI

final class APIViewModel: ObservableObject {
    @AppStorage("savedAPIKey") var SavedAPIKey: String = ""
    
    init() {
        self.SavedAPIKey = SavedAPIKey
    }
}
