//
//  File.swift
//  
//
//  Created by linhey on 2023/9/22.
//

import Foundation

struct OAIFile: Codable, Identifiable {
    
    enum Purpose: String,Codable {
        case fine_tune = "fine-tune"
    }
    
    enum Status: String, Codable {
        case uploaded
        case processed
        case pending
        case error
        case deleting
        case deleted
    }
    
    enum Object: String, Codable {
        case file
    }
    
    /// 文件的唯一标识符，可在API端点中引用。
    let id: String
    /// 对象类型，始终为 "file"。
    let object: Object
    /// 文件大小（以字节为单位）。
    let bytes: Int
    /// 文件创建的Unix时间戳（以秒为单位）。
    let created_at: Int
    /// 文件名称。
    let filename: String
    /// 文件的预期用途。目前仅支持 "fine-tune"。
    let purpose: Purpose
    /// 文件的当前状态，可以是 uploaded, processed, pending, error, deleting, 或 deleted。
    let status: Status
    /// 关于文件状态的额外细节。如果文件处于错误状态，此字段将包含描述错误的消息。可为null。
    let status_details: String?
}


struct FileAPIs {
    
    public let client: OAIClientProtocol
    public let serivce: OAISerivce
    
    public init(client: OAIClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }

    /// GET https://api.openai.com/v1/files
    /// Returns a list of files that belong to the user's organization.
    func list() async throws -> [OAIFile] {
        let request = client.request(of: serivce, path: "v1/files")
        let data = try await client.data(for: request)
        return try client.decode(OAIDataResponse<[OAIFile]>.self, from: data).data
    }
    
    /// Upload file
    /// POST https://api.openai.com/v1/files
    /// Upload a file that contains document(s) to be used across various endpoints/features. Currently, the size of all the files uploaded by one organization can be up to 1 GB. Please contact us if you need to increase the storage limit.
    func upload(data: Data, purpose: OAIFile.Purpose) async throws -> OAIFile {
        var request = client.request(of: serivce, path: "v1/files")
        request.method = .post
        request.headerFields[.contentType] = "multipart/form-data; boundary=\(UUID().uuidString)"
        let data = try await client.upload(for: request, from: data)
        return try client.decode(data)
    }
    
    func delete(id: OAIFile.ID) async throws {
        var request = client.request(of: serivce, path: "v1/files/\(id)")
        request.method = .delete
        _ = try await client.data(for: request)
    }
    
    func retrieve(id: OAIFile.ID) async throws -> OAIFile {
        let request = client.request(of: serivce, path: "v1/files/\(id)")
        let data = try await client.data(for: request)
        return try client.decode(data)
    }
    
    func retrieveContent(id: OAIFile.ID) async throws -> Data {
        let request = client.request(of: serivce, path: "v1/files/\(id)/content")
        return try await client.data(for: request).data
    }
    
}
