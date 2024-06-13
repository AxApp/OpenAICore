//
//  File.swift
//  
//
//  Created by linhey on 2024/5/23.
//

import Foundation
import STJSON

public struct OpenAICompatibilityFilePaths {
    
    let file_list: String
    let file_upload: String
    let file_delete: String
    let file_retrieve: String
    let file_content: String
    
    init(_ paths: LLMAPIPath) {
        self.file_list     = paths.prefix + "/files"
        self.file_upload   = paths.prefix + "/files"
        self.file_delete   = paths.prefix + "/files/:id/"
        self.file_retrieve = paths.prefix + "/files/:id/"
        self.file_content  = paths.prefix + "/files/:id/content"
    }
    
    func id(_ id: String, _ path: KeyPath<OpenAICompatibilityFilePaths, String>) -> String {
        self[keyPath: path].replacingOccurrences(of: "/:id/", with: "/\(id)/")
    }
    
}

/// openai: https://platform.openai.com/docs/api-reference/files
/// moonshot: https://platform.moonshot.cn/docs/api/partial#partial-mode
/// qwen: https://help.aliyun.com/zh/dashscope/developer-reference/openai-file-interface?spm=a2c4g.11186623.0.0.230b7defwUoypA#c067b349252tu
public protocol OpenAICompatibilityFileAPICollection: LLMAPICollection {
   
    associatedtype File: Codable & Identifiable where File.ID == String
    associatedtype Purpose: RawRepresentable where Purpose.RawValue == String
    associatedtype Deleted: Codable
    
    var client: LLMClientProtocol { get }
    var serivce: LLMSerivce { get }
    var file_paths: OpenAICompatibilityFilePaths { get }
}

public extension OpenAICompatibilityFileAPICollection {
    
    func file_list() async throws -> [File] {
        let request = client.request(of: serivce, path: file_paths.file_list)
        let response = try await client.data(for: request)
        try validate(response)
        return try client.decode(OAIDataResponse<[File]>.self, from: response).data
    }
    
    func file_upload(_ file: URL, purpose: Purpose) async throws -> File {
        var request = client.request(of: serivce, path: file_paths.file_upload)
        request.method = .post
        let response = try await client.upload(for: request, from: [.file(.init(fileURL: file, name: "file")),
                                                                    .string(name: "purpose", value: purpose.rawValue)])
        try validate(response)
        return try client.decode(response)
    }
    
    func file_delete(id: [File.ID]) async throws -> [Deleted] {
       try await withThrowingTaskGroup(of: Deleted.self) { group in
           for id in id {
               group.addTask {
                   try await file_delete(id: id)
               }
           }
            
            var list = [Deleted]()
            for try await result in group {
                list.append(result)
            }
            return list
        }
    }
    
    func file_delete(id: File.ID) async throws -> Deleted {
        var request = client.request(of: serivce, path: file_paths.id(id, \.file_delete))
        request.method = .delete
        let response = try await client.data(for: request)
        try validate(response)
        return try client.decode(response)
    }
    
    func file_retrieve(id: File.ID) async throws -> File {
        let request = client.request(of: serivce, path:file_paths.id(id, \.file_retrieve))
        let response = try await client.data(for: request)
        try validate(response)
        return try client.decode(response)
    }
    
    /// 通义千问不支持该接口
    /// openai 不支持 purpose: user_data / assistants
    /// Kimi 支持文件内容提取
    func file_content(id: File.ID) async throws -> OpenAICompatibilityFile.Content {
        let request = client.request(of: serivce, path: file_paths.id(id, \.file_content))
        let response = try await client.data(for: request)
        try validate(response)
        return try client.decode(response)
    }
}
