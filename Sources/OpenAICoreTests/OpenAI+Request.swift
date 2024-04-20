//
//  File.swift
//
//
//  Created by linhey on 2023/5/19.
//

import Foundation
import Combine
import OpenAICore
import HTTPTypes
import HTTPTypesFoundation

public class OAIClient: LLMClientProtocol {
    
    public static let shared = OAIClient()
    
    private var cancellables = Set<AnyCancellable>()
    
    public func data(for request: HTTPRequest) async throws -> LLMResponse {
        let response = try await URLSession.shared.data(for: request)
        return .init(data: response.0, response: response.1)
    }
    
    public func upload(for request: HTTPRequest, from bodyData: Data) async throws -> LLMResponse {
        let response = try await URLSession.shared.upload(for: request, from: bodyData)
        return .init(data: response.0, response: response.1)
    }
    
    public func serverSendEvent(for request: HTTPTypes.HTTPRequest, 
                                from bodyData: Data,
                                failure: (OpenAICore.LLMResponse) async throws -> Void) async throws -> AsyncThrowingStream<Data, any Error> {
        .makeStream().stream
    }
}
