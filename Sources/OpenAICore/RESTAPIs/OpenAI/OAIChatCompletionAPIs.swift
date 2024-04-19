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
    public let create_path: String
    
    public init(client: OAIClientProtocol, serivce: OAISerivce, create_path: String = "v1/chat/completions") {
        self.client = client
        self.serivce = serivce
        self.create_path = create_path
    }

    public func create<Returning: Codable>(_ parameter: Codable, returning: Returning.Type) async throws -> Returning {
        var request = client.request(of: serivce, path: create_path)
        request.method = .post
        let parameter = parameter
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
        var request = client.request(of: serivce, path: create_path)
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
    
    public func stream(_ parameter: Codable) async throws -> AsyncThrowingStream<OAIChatCompletion.CreateResponse, Error> {
        let (stream, continuation) = AsyncThrowingStream<OAIChatCompletion.CreateResponse, Error>.makeStream()
        let data_stream = try await create(dataStream: parameter)

        Task {
            do {
                let merge = OAIChatCompletionStreamMerge()
                for try await data in data_stream {
                    for chunk in try await merge.parse(chunk: data) {
                        switch chunk {
                        case .chunk(let data):
                            try await merge.append(JSONDecoder.decode(OAIChatCompletion.CreateChunkResponse.self, from: data))
                        case .finish:
                            break
                        case .other(let data):
                            break
                        }
                    }
                    await continuation.yield(merge.merge())
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
        return try await self.stream(parameter)
    }
    
}
