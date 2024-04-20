//
//  File.swift
//  
//
//  Created by linhey on 2023/3/23.
//

import Foundation

public struct OAIModel: Codable, Identifiable {
    
    public let id: String
    public let object: String
    public let created: Int
    public let owned_by: String
    
}


public struct OAIModelAPIs {
    
    public let client: LLMClientProtocol
    public let serivce: OAISerivce
    
    public init(client: LLMClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }
    
    public func list() async throws -> [OAIModel] {
        let request = client.request(of: serivce, path: "v1/models")
        let data = try await client.data(for: request)
        return try client.decode(OAIDataResponse<[OAIModel]>.self, from: data).data
    }
    
    public func retrieve(id: OAIModel.ID) async throws -> OAIModel {
        let request = client.request(of: serivce, path: "v1/models/\(id)")
        let data = try await client.data(for: request)
        return try client.decode(data)
    }
    
    public struct DeletedResponse: Codable {
        let id: OAIModel.ID
        let object: String
        let deleted: Bool
    }
    
    public func delete(id: OAIModel.ID) async throws -> DeletedResponse {
        var request = client.request(of: serivce, path: "v1/models/\(id)")
        request.method = .delete
        let data = try await client.data(for: request)
        return try client.decode(data)
    }
}
