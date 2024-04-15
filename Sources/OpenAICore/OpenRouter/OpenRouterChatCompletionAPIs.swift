//
//  File.swift
//  
//
//  Created by linhey on 2024/4/15.
//

import Foundation
import STJSON
import AnyCodable

public struct OpenRouterChatCompletionAPIs {

    public let openai: OAIChatCompletionAPIs
    
    public init(client: OAIClientProtocol, serivce: OAISerivce) {
        self.openai = .init(client: client, serivce: serivce, create_path: "api/v1/chat/completions")
    }
    
    public func create(_ parameter: OpenRouterChatCompletion.CreateParameter) async throws -> OAIChatCompletion.CreateResponse {
        var parameter = parameter
        parameter.stream = false
        return try await openai.create(parameter, returning: OAIChatCompletion.CreateResponse.self)
    }
    
    public func create(stream parameter: OpenRouterChatCompletion.CreateParameter) async throws -> AsyncThrowingStream<OAIChatCompletion.CreateResponse, Error> {
        var parameter = parameter
        parameter.stream = true
        return try await openai.stream(parameter)
    }
    
}
