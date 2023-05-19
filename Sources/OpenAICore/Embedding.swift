//
//  File.swift
//  
//
//  Created by linhey on 2023/3/23.
//

import Foundation

///MARK: - Embeddings
public struct OAIEmbeddings: OAIAPI {
    
    public let path: OAIPath = .embeddings
    public let query: Query
    
    public init(query: Query) {
        self.query = query
    }
    
    public struct Query: Codable, OAIAPIQuery {
        /// ID of the model to use.
        public let model: String
        /// Input text to get embeddings for
        public let input: String
        
        public init(model: OpenAIModel, input: String) {
            self.model = model.name
            self.input = input
        }
    }
    
    public struct Response: Codable {
        
        public struct Embedding: Codable {
            public let object: String
            public let embedding: [Double]
            public let index: Int
        }
        public let data: [Embedding]
    }
    
}

