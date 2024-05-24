//
//  File.swift
//
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public protocol OpenAIAPICollection: LLMAPICollection {
    var client: LLMClientProtocol { get }
    var serivce: LLMSerivce { get }
}

public extension OpenAIAPICollection {
        
    func embeddings(_ parameters: OllamaEmbeddings.Parameters) async throws -> OllamaEmbeddings.Response {
        return try await upload("v1/embeddings", parameters, method: .post)
    }

    func chat_completions(_ parameters: OAIChatCompletion.Parameters) async throws -> OAIChatCompletion.Response {
        try await upload("v1/chat/completions", parameters, method: .post)
    }
    
    func chat_completions(streamChunk parameters: OAIChatCompletion.Parameters) async throws -> AsyncThrowingStream<OAIChatCompletion.StreamResponse, any Error> {
        var parameters = parameters
        parameters.stream = true
        var request = client.request(of: serivce, path: "v1/chat/completions")
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
    
    func chat_completions(stream parameters: OAIChatCompletion.Parameters) async throws -> AsyncThrowingStream<OAIChatCompletion.Response, Error> {
        var merge = OAIChatCompletionStreamMerge()
        return transform(stream: try await chat_completions(streamChunk: parameters)) { element in
            merge.append(element)
            return merge.merge()
        }
    }
}
