//
//  File.swift
//  
//
//  Created by linhey on 2024/5/22.
//

import Foundation
import STJSON

public protocol OpenAICompatibilityChatAPICollection: LLMAPICollection {
    var client: LLMClientProtocol { get }
    var serivce: LLMSerivce { get }
    var paths: LLMAPIPath { get }
}

public extension OpenAICompatibilityChatAPICollection {
    
    func chat_completions(_ parameters: OpenAICompatibilityChatCompletion.Parameters,
                          options: OpenAICompatibilityChatCompletion.Options? = nil) async throws -> OAIChatCompletion.Response {
        try await upload(paths.prefix + "/chat/completions", 
                         parameters.toJSON.merged(with: options?.toJSON ?? JSON()),
                         method: .post)
    }
    
    func chat_completions(streamChunk parameters: OpenAICompatibilityChatCompletion.Parameters,
                          options: OpenAICompatibilityChatCompletion.Options? = nil) async throws -> AsyncThrowingStream<OAIChatCompletion.StreamResponse, any Error> {
        var parameters = parameters
        parameters.stream = true
        var request = client.request(of: serivce, path: paths.prefix + "/chat/completions")
        request.method = .post
        let request_body = try client.encode(parameters.toJSON.merged(with: options?.toJSON ?? JSON()))
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
    
    func chat_completions(stream parameters: OpenAICompatibilityChatCompletion.Parameters,
                          options: OpenAICompatibilityChatCompletion.Options? = nil) async throws -> AsyncThrowingStream<OAIChatCompletion.Response, Error> {
        var merge = OAIChatCompletionStreamMerge()
        return transform(stream: try await chat_completions(streamChunk: parameters, options: options)) { element in
            merge.append(element)
            return merge.merge()
        }
    }
}

