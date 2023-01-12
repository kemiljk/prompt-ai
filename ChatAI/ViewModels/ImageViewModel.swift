//
//  ImageViewModel.swift
//  Prompt
//
//  Created by Karl Koch on 31/12/2022.
//

import SwiftUI
import OpenAIKit

final class ImageViewModel: ObservableObject {
    @ObservedObject var APIKey = APIViewModel()
    private var openai: OpenAI?
    
    @Published var isLoading: Bool = false
    @Published var error: Bool = false
    

    func setup() {
        openai = OpenAI(
            Configuration(organization: "Personal", apiKey: APIKey.SavedAPIKey)
        )
    }
    
    func updateKey() {
        openai = OpenAI(
            Configuration(organization: "Personal", apiKey: APIKey.SavedAPIKey)
        )
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        guard let openai = openai else {
            return nil
        }
        
        do {
            let params = ImageParameters(prompt: prompt, resolution: .medium, responseFormat: .base64Json)
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return image
        } catch {
            print(String(describing: error))
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = true
            }
            return nil
        }
        
    }
}
