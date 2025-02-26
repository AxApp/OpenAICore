//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation
import HTTPTypes

public protocol LLMAPICollection {
    var client: LLMClientProtocol { get }
    var serivce: LLMSerivce { get }
}

public struct LLMAPIResponseError: LocalizedError {
    public let response: LLMResponse
    public var errorDescription: String? {
        return String.init(data: response.data, encoding: .utf8)
    }
}

public extension LLMAPICollection {
    
    func validate<Response: Decodable>(_ response: LLMResponse) throws -> Response {
        guard response.response.status.kind != .successful else {
            return try JSONDecoder.decode(Response.self, from: response.data)
        }
        
        if let error = try? JSONDecoder.decode(OAIErrorResponse.self, from: response.data) {
            throw error.error
        } else if let error = try? JSONDecoder.decode(OllamaError.self, from: response.data) {
            throw error
        } else if let error = try? JSONDecoder.decode(OAIError.self, from: response.data) {
            throw error
        } else {
            throw OllamaError(error: String.init(data: response.data, encoding: .utf8) ?? "")
        }
    }
    
    func validate(_ response: LLMResponse) throws -> Void {
        guard response.response.status.kind != .successful else {
            return
        }
        
        if let error = try? JSONDecoder.decode(OAIErrorResponse.self, from: response.data) {
            throw error.error
        } else if let error = try? JSONDecoder.decode(OllamaError.self, from: response.data) {
            throw error
        } else if let error = try? JSONDecoder.decode(OAIError.self, from: response.data) {
            throw error
        } else {
            throw LLMAPIResponseError(response: response)
        }
    }
    
    func data(_ path: String,
              method: HTTPRequest.Method,
              beforeRequest: ((inout HTTPRequest) -> Void)? = nil) async throws {
        var request = client.request(of: serivce, path: path)
        request.method = method
        beforeRequest?(&request)
        let response = try await client.data(for: request)
        return try validate(response)
    }
    
    func data<Response: Decodable>(_ path: String,
                                   method: HTTPRequest.Method,
                                   beforeRequest: ((inout HTTPRequest) -> Void)? = nil) async throws -> Response {
        var request = client.request(of: serivce, path: path)
        request.method = method
        beforeRequest?(&request)
        let response = try await client.data(for: request)
        return try validate(response)
    }
    
    func upload<Parameters: Encodable, Response: Decodable>(_ path: String,
                                                            _ parameters: Parameters,
                                                            method: HTTPRequest.Method,
                                                            beforeRequest: ((inout HTTPRequest) -> Void)? = nil,
                                                            afterResponse: ((_ response: LLMResponse) async throws -> LLMResponse)? = nil) async throws -> Response {
        var request = client.request(of: serivce, path: path)
        request.method = method
        let request_body = try client.encode(parameters)
        beforeRequest?(&request)
        var response = try await client.upload(for: request, from: request_body)
        if let afterResponse = afterResponse {
            response = try await afterResponse(response)
        }
        return try validate(response)
    }
    
    func upload<Parameters: Encodable>(_ path: String,
                                       _ parameters: Parameters,
                                       method: HTTPRequest.Method,
                                       beforeRequest: ((inout HTTPRequest) -> Void)? = nil) async throws -> Void {
        var request = client.request(of: serivce, path: path)
        request.method = method
        let request_body = try client.encode(parameters)
        beforeRequest?(&request)
        let response = try await client.upload(for: request, from: request_body)
        return try validate(response)
    }
    
}
