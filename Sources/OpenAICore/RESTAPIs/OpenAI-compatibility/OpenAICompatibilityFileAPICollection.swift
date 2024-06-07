//
//  File.swift
//  
//
//  Created by linhey on 2024/5/23.
//

import Foundation
import STJSON

/// openai: https://platform.openai.com/docs/api-reference/files
/// moonshot: https://platform.moonshot.cn/docs/api/partial#partial-mode
/// qwen: https://help.aliyun.com/zh/dashscope/developer-reference/openai-file-interface?spm=a2c4g.11186623.0.0.230b7defwUoypA#c067b349252tu
public protocol OpenAICompatibilityFileAPICollection: LLMAPICollection {
   
    associatedtype File: Codable & Identifiable
    associatedtype Purpose: RawRepresentable where Purpose.RawValue == String
    associatedtype Deleted: Codable
    
    var client: LLMClientProtocol { get }
    var serivce: LLMSerivce { get }
    var paths: LLMAPIPath { get }
}

public extension OpenAICompatibilityFileAPICollection {
    
    func file_list() async throws -> [File] {
        let request = client.request(of: serivce, path: "v1/files")
        let response = try await client.data(for: request)
        try validate(response)
        return try client.decode(OAIDataResponse<[File]>.self, from: response).data
    }
    
    func file_upload(_ file: URL, purpose: Purpose) async throws -> File {
        var request = client.request(of: serivce, path: paths.prefix + "/files")
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
        var request = client.request(of: serivce, path: paths.prefix + "/files/\(id)")
        request.method = .delete
        let response = try await client.data(for: request)
        try validate(response)
        return try client.decode(response)
    }
    
    func file_retrieve(id: File.ID) async throws -> File {
        let request = client.request(of: serivce, path: paths.prefix + "/files/\(id)")
        let response = try await client.data(for: request)
        try validate(response)
        return try client.decode(response)
    }
    
    /// 通义千问不支持该接口
    /// openai 不支持 purpose: user_data / assistants
    /// Kimi 支持文件内容提取
    func file_content(id: File.ID) async throws -> OpenAICompatibilityFile.Content {
        let request = client.request(of: serivce, path: paths.prefix + "/files/\(id)/content")
        let response = try await client.data(for: request)
        try validate(response)
        return try client.decode(response)
    }
}
