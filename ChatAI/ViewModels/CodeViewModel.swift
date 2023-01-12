//
//  TextViewModel.swift
//  Prompt
//
//  Created by Karl Koch on 31/12/2022.
//

import OpenAISwift
import SwiftUI

final class CodeViewModel: ObservableObject {
    @ObservedObject var APIKey = APIViewModel()
    private var openAPI: OpenAISwift?
    
    @Published var isLoading: Bool = false
    @Published var error: Bool = false

    func setup() {
        openAPI = OpenAISwift(authToken: APIKey.SavedAPIKey)
    }
    
    func updateKey() {
        openAPI = OpenAISwift(authToken: APIKey.SavedAPIKey)
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        openAPI?.sendCompletion(with: text, model: .codex(.davinci), maxTokens: 1000, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = true
                }
            }
        })
    }
}
    
