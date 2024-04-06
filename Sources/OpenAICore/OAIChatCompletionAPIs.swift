//
//  File.swift
//  
//
//  Created by linhey on 2024/4/4.
//

import Foundation
import STJSON

public struct OAIChatCompletionAPIs {
    
    public let client: OAIClientProtocol
    public let serivce: OAISerivce
    
    public init(client: OAIClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }
    
    public func create(_ parameter: OAIChatCompletion.CreateParameter) async throws -> OAIChatCompletion.CreateResponse {
        var request = client.request(of: serivce, path: "v1/chat/completions")
        request.method = .post
        var parameter = parameter
        parameter.stream = false
        let request_body = try client.encode(parameter)
        let data = try await client.upload(for: request, from: request_body)
        return try client.decode(data)
    }
    
    
    public func create(stream parameter: OAIChatCompletion.CreateParameter) async throws -> AsyncThrowingStream<OAIChatCompletion.CreateResponse, Error> {
        var request = client.request(of: serivce, path: "v1/chat/completions")
        request.method = .post
        var parameter = parameter
        parameter.stream = true
        let request_body = try client.encode(parameter)
        let (stream, continuation) = AsyncThrowingStream<OAIChatCompletion.CreateResponse, Error>.makeStream()
        let data_stream = try client.stream(for: request, from: request_body)
        let streamMerge = OAIChatCompletionStreamMerge()
        
        do {
            for try await data in data_stream {
                try await streamMerge.append(chunk: data.data)
                await continuation.yield(streamMerge.merge())
            }
            continuation.finish()
        } catch {
            print(error)
            continuation.finish(throwing: error)
        }
        return stream
    }
    
}
