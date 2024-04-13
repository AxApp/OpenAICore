//
//  File.swift
//  
//
//  Created by linhey on 2024/4/4.
//

import Foundation
import STJSON
import AnyCodable

public struct OAIChatCompletionAPIs {
    
    public let client: OAIClientProtocol
    public let serivce: OAISerivce
    
    public init(client: OAIClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }

    public func create<Returning: Codable>(_ parameter: Codable, returning: Returning.Type) async throws -> Returning {
        var request = client.request(of: serivce, path: "v1/chat/completions")
        request.method = .post
        var parameter = parameter
        let request_body = try client.encode(parameter)
        let data = try await client.upload(for: request, from: request_body)
        return try client.decode(data)
    }
    
    public func create(_ parameter: OAIChatCompletion.CreateParameter) async throws -> OAIChatCompletion.CreateResponse {
        var parameter = parameter
        parameter.stream = false
        return try await create(parameter, returning: OAIChatCompletion.CreateResponse.self)
    }

    public func create(dataStream parameter: Codable) async throws -> AsyncThrowingStream<Data, Error> {
        var request = client.request(of: serivce, path: "v1/chat/completions")
        request.method = .post
        let request_body = try client.encode(parameter)
        let (stream, continuation) = AsyncThrowingStream<Data, Error>.makeStream()
        let data_stream = try await client.serverSendEvent(for: request, from: request_body, failure: { response in
            if let error = try? JSONDecoder.decode(OAIErrorResponse.self, from: response.data) {
                throw error.error
            } else {
                throw OAIError(type: .server_error, message: .init(data: response.data, encoding: .utf8))
            }
        })
        Task {
            do {
                for try await data in data_stream {
                    continuation.yield(data)
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        return stream
    }
    
    public func create(stream parameter: OAIChatCompletion.CreateParameter) async throws -> AsyncThrowingStream<OAIChatCompletion.CreateResponse, Error> {
        var parameter = parameter
        parameter.stream = true
        let (stream, continuation) = AsyncThrowingStream<OAIChatCompletion.CreateResponse, Error>.makeStream()
        let data_stream = try await create(dataStream: parameter)

        Task {
            do {
                let streamMerge = OAIChatCompletionStreamMerge()
                for try await data in data_stream {
                    try await streamMerge.append(chunk: data)
                    await continuation.yield(streamMerge.merge())
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        
        return stream
    }
    
}
