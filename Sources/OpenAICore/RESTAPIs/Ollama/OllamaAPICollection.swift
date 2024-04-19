//
//  File 2.swift
//
//
//  Created by linhey on 2024/4/19.
//

import Foundation
import HTTPTypes

public protocol OllamaAPICollection {
    var client: OAIClientProtocol { get }
    var serivce: LLMSerivce { get }
}


/// https://github.com/ollama/ollama/blob/main/docs/api.md#model-names
public extension OllamaAPICollection {
    
    func embeddings(_ parameters: OllamaEmbeddings.Parameters) async throws -> OllamaEmbeddings.Response {
        return try await upload("api/embeddings", parameters, method: .post)
    }
    
    func push(_ parameters: OllamaPushModel.Parameters) async throws -> OllamaPushModel.Response {
        return try await upload("api/push", parameters, method: .post)
    }
    
    func pull(_ parameters: OllamaPullModel.Parameters) async throws -> OllamaPullModel.Response {
        return try await upload("api/pull", parameters, method: .post)
    }
    
    func delete(_ parameters: OllamaDeleteModel.Parameters) async throws -> OllamaDeleteModel.Response {
        return try await upload("api/delete", parameters, method: .delete)
    }
    
    func copy(_ parameters: OllamaCopyModel.Parameters) async throws -> OllamaCopyModel.Response {
        return try await upload("api/copy", parameters, method: .post)
    }
    
    func show(_ parameters: OllamaShowModel.Parameters) async throws -> OllamaShowModel.Response {
        return try await upload("api/show", parameters, method: .post)
    }
    
    func list() async throws -> OllamaModelList.Response {
        return try await data("api/tags", method: .get)
    }
    
    func create(_ parameters: OllamaCreateModel.Parameters) async throws -> OllamaCreateModel.Response {
        return try await upload("api/create", parameters, method: .post)
    }
    
    
    //    func blobs_create(_ parameters: OllamaCreateBlob.Parameters) async throws -> OllamaCreateBlob.Response {
    //        return try await upload("api/blobs/\(parameters.digest)", parameters, method: .post)
    //    }
    
    func blobs_check(_ parameters: OllamaCreateBlob.Parameters) async throws {
        return try await data("api/blobs/sha256:\(parameters.digest)", method: .head)
    }
    
    func generate(_ parameters: OllamaGenerate.Parameters) async throws -> OllamaGenerate.Response {
        return try await upload("api/generate", parameters, method: .post)
    }
    func generate(stream parameters: OllamaGenerate.Parameters) async throws -> AsyncThrowingStream<OllamaGenerate.StreamResponse, Error> {
        var parameters = parameters
        parameters.stream = true
        var request = client.request(of: serivce, path: "api/generate")
        request.method = .post
        let request_body = try client.encode(parameters)
        let (stream, continuation) = AsyncThrowingStream<OllamaGenerate.StreamResponse, Error>.makeStream()
        let data_stream = try await client.serverSendEvent(for: request, from: request_body) { response in
            try validate(response)
        }
        
        Task {
            do {
                var response = OllamaGenerate.StreamResponse.init(model: "",
                                                                  created_at: "",
                                                                  response: "",
                                                                  done: false)
                
                for try await data in data_stream {
                    for line in String(data: data, encoding: .utf8)?
                        .split(separator: "\n", omittingEmptySubsequences: true)
                        .map(\.description) ?? [] {
                        if let stream = try? JSONDecoder.decode(OllamaGenerate.StreamResponse.self, from: line) {
                            response.merge(stream: stream)
                            continuation.yield(response)
                        }
                    }
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        return stream
    }
    
    func chat(_ parameters: OllamaChat.Parameters) async throws -> OllamaChat.Response {
        return try await upload("api/chat", parameters, method: .post)
    }
    
    func chat(stream parameters: OllamaChat.Parameters) async throws -> AsyncThrowingStream<OllamaChat.Response, Error> {
        var parameters = parameters
        parameters.stream = true
        var request = client.request(of: serivce, path: "api/chat")
        request.method = .post
        let request_body = try client.encode(parameters)
        let (stream, continuation) = AsyncThrowingStream<OllamaChat.Response, Error>.makeStream()
        let data_stream = try await client.serverSendEvent(for: request, from: request_body) { response in
            try validate(response)
        }
        
        Task {
            do {
                var response = OllamaChat.Response.init(model: "",
                                                     created_at: "",
                                                     message: .init(role: .assistant, content: ""),
                                                     done: false,
                                                     total_duration: 0,
                                                     load_duration: 0,
                                                     prompt_eval_count: 0,
                                                     prompt_eval_duration: 0,
                                                     eval_count: 0,
                                                     eval_duration: 0)
                
                for try await data in data_stream {
                    for line in String(data: data, encoding: .utf8)?
                        .split(separator: "\n", omittingEmptySubsequences: true)
                        .map(\.description) ?? [] {
                        if let stream = try? JSONDecoder.decode(OllamaChat.StreamResponse.self, from: line) {
                            response.merge(stream: stream)
                            continuation.yield(response)
                        }
                    }
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        return stream
    }
    
}

extension OllamaAPICollection {
    
    func validate<Response: Decodable>(_ response: OAIClientResponse) throws -> Response {
        if response.response.status.kind != .successful {
            if let error = try? JSONDecoder.decode(OllamaError.self, from: response.data) {
                throw error
            } else {
                throw OllamaError(error: String.init(data: response.data, encoding: .utf8) ?? "")
            }
        }
        return try JSONDecoder.decode(Response.self, from: response.data)
    }
    
    func validate(_ response: OAIClientResponse) throws -> Void {
        if response.response.status.kind != .successful {
            if let error = try? JSONDecoder.decode(OllamaError.self, from: response.data) {
                throw error
            } else {
                throw OllamaError(error: String.init(data: response.data, encoding: .utf8) ?? "")
            }
        }
    }
    
    func data(_ path: String,
              method: HTTPRequest.Method,
              beforeRequest: ((inout HTTPRequest) -> Void)? = nil) async throws {
        var request = client.request(of: serivce, path: path)
        request.method = method
        beforeRequest?(&request)
        let response = try await client.data(for: request)
        return try validate(response)
    }
    
    func data<Response: Decodable>(_ path: String,
                                   method: HTTPRequest.Method,
                                   beforeRequest: ((inout HTTPRequest) -> Void)? = nil) async throws -> Response {
        var request = client.request(of: serivce, path: path)
        request.method = method
        beforeRequest?(&request)
        let response = try await client.data(for: request)
        return try validate(response)
    }
    
    func upload<Parameters: Encodable, Response: Decodable>(_ path: String,
                                                            _ parameters: Parameters,
                                                            method: HTTPRequest.Method,
                                                            beforeRequest: ((inout HTTPRequest) -> Void)? = nil) async throws -> Response {
        var request = client.request(of: serivce, path: path)
        request.method = method
        let request_body = try client.encode(parameters)
        beforeRequest?(&request)
        let response = try await client.upload(for: request, from: request_body)
        return try validate(response)
    }
    
    func upload<Parameters: Encodable>(_ path: String,
                                       _ parameters: Parameters,
                                       method: HTTPRequest.Method,
                                       beforeRequest: ((inout HTTPRequest) -> Void)? = nil) async throws -> Void {
        var request = client.request(of: serivce, path: path)
        request.method = method
        let request_body = try client.encode(parameters)
        beforeRequest?(&request)
        let response = try await client.upload(for: request, from: request_body)
        return try validate(response)
    }
    
}
