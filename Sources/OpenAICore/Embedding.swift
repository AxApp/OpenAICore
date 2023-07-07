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
    
    public enum Model: String, Codable {
        case text_embedding_ada_002 = "text-embedding-ada-002"
        
        public var maxInputTokens: Int {
            switch self {
            case .text_embedding_ada_002:
                return 8191
            }
        }
        
        public var outputDimensions: Int {
            switch self {
            case .text_embedding_ada_002:
                return 1536
            }
        }
    }
    
    public init(query: Query) {
        self.query = query
    }
    
    public struct Query: Codable, OAIAPIQuery {
        /// ID of the model to use.
        public let model: String
        /// Input text to get embeddings for
        public let input: String
        
        public init(model: Model = .text_embedding_ada_002, input: String) {
            self.model = model.rawValue
            self.input = input
        }
    }
    
    public struct Response: Codable {
        
        public struct Embedding: Codable {
            public let object: String
            public let embedding: [Decimal]
            public let index: Int
        }
        
        public let object: String
        public let data: [Embedding]
        public let model: String
        public let usage: OAIUsage

    }
    
}

