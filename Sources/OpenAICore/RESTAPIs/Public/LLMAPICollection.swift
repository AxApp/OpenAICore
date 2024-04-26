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

public extension LLMAPICollection {
    
    func transform<Element, Transform, Failure: Error>(stream: AsyncThrowingStream<Element, Failure>,
                                                       transform: @escaping (_ element: Element) throws -> [Transform]) -> AsyncThrowingStream<Transform, Failure> where Failure == any Error {
            let (new_stream, new_continuation) = AsyncThrowingStream<Transform, Failure>.makeStream()
            Task {
                do {
                    for try await elemet in stream {
                        for item in try transform(elemet) {
                            new_continuation.yield(item)
                        }
                    }
                    new_continuation.finish()
                } catch {
                    new_continuation.finish(throwing: error)
                }
            }
            return new_stream
        }
    
    func transform<Element, Transform, Failure: Error>(stream: AsyncThrowingStream<Element, Failure>,
                                                       transform: @escaping (_ element: Element) throws -> Transform) -> AsyncThrowingStream<Transform, Failure> where Failure == any Error {
            let (new_stream, new_continuation) = AsyncThrowingStream<Transform, Failure>.makeStream()
            Task {
                do {
                    for try await elemet in stream {
                        new_continuation.yield(try transform(elemet))
                    }
                    new_continuation.finish()
                } catch {
                    new_continuation.finish(throwing: error)
                }
            }
            return new_stream
        }
    
}

public extension LLMAPICollection {
    
    func validate<Response: Decodable>(_ response: LLMResponse) throws -> Response {
        if response.response.status.kind != .successful {
            if let error = try? JSONDecoder.decode(OllamaError.self, from: response.data) {
                throw error
            } else {
                throw OllamaError(error: String.init(data: response.data, encoding: .utf8) ?? "")
            }
        }
        return try JSONDecoder.decode(Response.self, from: response.data)
    }
    
    func validate(_ response: LLMResponse) throws -> Void {
        if response.response.status.kind != .successful {
            if let error = try? JSONDecoder.decode(OllamaError.self, from: response.data) {
                throw error
            } else if let error = try? JSONDecoder.decode(OAIErrorResponse.self, from: response.data) {
                throw error.error
            } else {
                throw OllamaError(error: String.init(data: response.data, encoding: .utf8) ?? "")
            }
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
                                                            beforeRequest: ((inout HTTPRequest) -> Void)? = nil) async throws -> Response {
        var request = client.request(of: serivce, path: path)
        request.method = method
        let request_body = try client.encode(parameters)
        beforeRequest?(&request)
        let response = try await client.upload(for: request, from: request_body)
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
