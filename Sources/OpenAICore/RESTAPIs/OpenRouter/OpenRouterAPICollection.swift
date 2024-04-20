//
//  File.swift
//  
//
//  Created by linhey on 2024/4/15.
//

import Foundation
import STJSON
import AnyCodable


public protocol OpenRouterAPICollection: LLMAPICollection {
    var client: LLMClientProtocol { get }
    var serivce: LLMSerivce { get }
}

public extension OpenRouterAPICollection {
    
    func chat_completions(_ parameters: OpenRouterChatCompletion.Parameters) async throws -> OAIChatCompletion.Response {
        try await upload("api/v1/chat/completions", parameters, method: .post)
    }
    
    func chat_completions(streamChunk parameters: OpenRouterChatCompletion.Parameters) async throws -> AsyncThrowingStream<OAIChatCompletion.StreamResponse, any Error> {
        var parameters = parameters
        parameters.stream = true
        var request = client.request(of: serivce, path: "api/v1/chat/completions")
        request.method = .post
        let request_body = try client.encode(parameters)
        let stream = try await client.serverSendEvent(for: request, from: request_body) { response in
            try validate(response)
        }
        
        let merge = OAIChatCompletionStreamMerge()
        return transform(stream: stream) { element in
           var chunks = [OAIChatCompletion.StreamResponse]()
            for chunk in try merge.parse(chunk: element) {
                switch chunk {
                case .chunk(let data):
                    try chunks.append(JSONDecoder.decode(OAIChatCompletion.StreamResponse.self, from: data))
                case .finish:
                    break
                case .other:
                    break
                }
            }
            return chunks
        }
    }
    
    func chat_completions(stream parameters: OpenRouterChatCompletion.Parameters) async throws -> AsyncThrowingStream<OAIChatCompletion.Response, Error> {
        var merge = OAIChatCompletionStreamMerge()
        return transform(stream: try await chat_completions(streamChunk: parameters)) { element in
            merge.append(element)
            return merge.merge()
        }
    }
}

