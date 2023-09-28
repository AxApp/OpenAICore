//
//  File.swift
//
//
//  Created by linhey on 2023/3/23.
//

import Foundation

public struct OAIEmbedding: Codable {
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

public struct OAIEmbeddingAPIs {
    
    public let client: OAIClientProtocol
    public let serivce: OAISerivce
    
    public init(client: OAIClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }
    
    public enum EmbeddingModel: String, Codable {
        case text_embedding_ada_002 = "text-embedding-ada-002"
    }
    
    public struct CreateParameter: Codable {
        var model: EmbeddingModel
        var input: [String]
        var user: String?
        
        public init(model: EmbeddingModel, input: [String], user: String? = nil) {
            self.model = model
            self.input = input
            self.user = user
        }
    }
    
    public func create(_ parameter: CreateParameter) async throws -> [OAIEmbedding] {
        var request = client.request(of: serivce, path: "v1/embeddings")
        request.method = .post
        let request_body = try client.encode(parameter)
        let data = try await client.upload(for: request, from: request_body)
        return try client.decode(data)
    }
    
}
