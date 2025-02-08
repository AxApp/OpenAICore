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
import Alamofire

public class OAIClient: LLMClientProtocol {

    
    public static let shared = OAIClient()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        URLSession.shared.configuration.timeoutIntervalForRequest = 5 * 60
        URLSession.shared.configuration.timeoutIntervalForResource = 5 * 60
    }
    
    public func data(for request: HTTPRequest) async throws -> LLMResponse {
        let response = try await URLSession.shared.data(for: request)
        return .init(data: response.0, response: response.1)
    }
    
    public func data(for request: HTTPRequest, progress: RequestProgress?) async throws -> LLMResponse {
        let response = try await URLSession.shared.data(for: request)
        return .init(data: response.0, response: response.1)
    }
    
    public func upload(for request: HTTPRequest, from fields: [LLMMultipartField]) async throws -> LLMResponse {
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
