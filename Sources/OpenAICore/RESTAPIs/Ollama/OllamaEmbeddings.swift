//
//  File.swift
//  
//
//  Created by linhey on 2024/4/18.
//

import Foundation

public struct OllamaEmbeddings {
    
    public struct Parameters: Codable {
        public let model: String
        public let prompt: String
        public init(model: String, prompt: String) {
            self.model = model
            self.prompt = prompt
        }
    }
    
    public struct Response: Codable {
        public let embedding: [Double]
        public init(embedding: [Double]) {
            self.embedding = embedding
        }
    }
    
}

