//
//  File.swift
//  
//
//  Created by linhey on 2024/5/22.
//

import Foundation
import STJSON

public struct OpenAICompatibilityChatPaths {
    let chat_completions: String
    
    init(chat_completions: String) {
        self.chat_completions = chat_completions
    }
    
    init(_ paths: LLMAPIPath) {
        self.init(chat_completions: paths.prefix + "/chat/completions")
    }
}

public protocol OpenAICompatibilityChatAPICollection: LLMAPICollection {
    var client: LLMClientProtocol { get }
    var serivce: LLMSerivce { get }
    var chat_paths: OpenAICompatibilityChatPaths { get }
}

public extension OpenAICompatibilityChatAPICollection {
    
    func chat_completions(_ parameters: OpenAICompatibilityChatCompletion.Parameters,
                          options: OpenAICompatibilityChatCompletion.Options? = nil) async throws -> OAIChatCompletion.Response {
        try await upload(chat_paths.chat_completions,
                         parameters.toJSON.merged(with: options?.toJSON ?? JSON()),
                         method: .post, afterResponse: { response in
            guard response.response.status.kind == .successful else {
                return response
            }
            
            var json = try JSON(data: response.data)
            /// fix: zhipuai
            if !json["object"].exists() {
                json["object"] = JSON(stringLiteral: OAIChatCompletion.Object.chat_completion.rawValue)
            }
            return LLMResponse(data: try json.rawData(), response: response.response)
        })
    }
    
//    func chat_completions(streamChunk parameters: OpenAICompatibilityChatCompletion.Parameters,
//                          options: OpenAICompatibilityChatCompletion.Options? = nil) async throws -> AsyncThrowingStream<OAIChatCompletion.StreamResponse, any Error> {
//        var parameters = parameters
//        parameters.stream = true
//        var request = client.request(of: serivce, path: chat_paths.chat_completions)
//        request.method = .post
//        let request_body = try client.encode(parameters.toJSON.merged(with: options?.toJSON ?? JSON()))
//        let stream = try await client.serverSendEvent(for: request, from: request_body) { response in
//            try validate(response)
//        }
//        
//        let merge = OAIChatCompletionStreamMerge()
//        return transform(stream: stream) { element in
//           var chunks = [OAIChatCompletion.StreamResponse]()
//            for chunk in try merge.parse(chunk: element) {
//                switch chunk {
//                case .chunk(let data):
//                    var json = try JSON(data: data)
//                    /// fix: zhipuai
//                    if !json["object"].exists() {
//                        json["object"] = JSON(stringLiteral: OAIChatCompletion.Object.chat_completion_chunk.rawValue)
//                    }
//                    
//                    try chunks.append(JSONDecoder.decode(OAIChatCompletion.StreamResponse.self, from: json.rawData()))
//                case .finish:
//                    break
//                case .other:
//                    break
//                }
//            }
//            return chunks
//        }
//    }
//    
//    func chat_completions(stream parameters: OpenAICompatibilityChatCompletion.Parameters,
//                          options: OpenAICompatibilityChatCompletion.Options? = nil) async throws -> AsyncThrowingStream<OAIChatCompletion.Response, Error> {
//        var merge = OAIChatCompletionStreamMerge()
//        return transform(stream: try await chat_completions(streamChunk: parameters, options: options)) { element in
//            merge.append(element)
//            return merge.merge()
//        }
//    }
}

