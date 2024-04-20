//
//  File.swift
//
//
//  Created by linhey on 2023/3/23.
//

import Foundation

public struct OAIEmbedding: Codable {
    
    public enum Model: String, Codable {
        case text_embedding_3_large = "text-embedding-3-large"
        case text_embedding_3_small = "text-embedding-3-small"
        case text_embedding_ada_002 = "text-embedding-ada-002"
    }
    
    public struct Parameters: Codable {
        public var model: Model
        public var input: [String]
        public var user: String?
        
        public init(model: Model = .text_embedding_ada_002,
                    input: [String],
                    user: String? = nil) {
            self.model = model
            self.input = input
            self.user = user
        }
        
        public init(model: Model = .text_embedding_ada_002,
                    input: String,
                    user: String? = nil) {
            self.model = model
            self.input = [input]
            self.user = user
        }
    }
    
    public struct Response: Codable {
        public enum Object: String, Codable {
            case embedding
        }
        
        /// Represents an embedding vector returned by embedding endpoint.
        
        /// The index of the embedding in the list of embeddings.
        public var index: Int
        
        /// The object type, which is always "embedding".
        public var object: Object
        
        /// The embedding vector, which is a list of floats. The length of the vector depends on the model as listed in the embedding guide.
        public var embedding: [Float]
        
        /// Initializes an EmbeddingObject with the given values.
        ///
        /// - Parameters:
        ///   - index: The index of the embedding in the list of embeddings.
        ///   - object: The object type, which is always "embedding".
        ///   - embedding: The embedding vector, which is a list of floats.
        public init(index: Int, object: Object = .embedding, embedding: [Float]) {
            self.index = index
            self.object = object
            self.embedding = embedding
        }
    }
    
    
}
