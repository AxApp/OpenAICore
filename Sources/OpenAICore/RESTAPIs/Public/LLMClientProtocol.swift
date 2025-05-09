//
//  File.swift
//  
//
//  Created by linhey on 2023/7/21.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation
import STJSON

public extension HTTPField.Name {
    static var userinfo = HTTPField.Name.init("userinfo")!
}

public struct LLMResponse: Sendable {
    
    public let data: Data
    public let response: HTTPResponse
    public init(data: Data, response: HTTPResponse) {
        self.data = data
        self.response = response
    }
    
    public func decode<Value: Decodable>(_ type: Value.Type, decoder: JSONDecoder = .shared) throws -> Value {
        try decoder.decode(Value.self, from: data)
    }
    
}

public enum LLMMultipartField {
    
    public struct File {
        
        public let fileURL: URL
        public let name: String
        public let fileName: String?
        public let mimeType: String?
        
        public init(fileURL: URL, name: String, fileName: String? = nil, mimeType: String? = nil) {
            self.fileURL = fileURL
            self.name = name
            self.fileName = fileName
            self.mimeType = mimeType
        }
        
    }
    
    case string(name: String, value: String)
    case file(File)
}

public protocol LLMClientProtocol {
    
    typealias RequestProgress = (_ total: Int64, _ completed: Int64) -> Void
    var encoder: JSONEncoder { get }
    var decoder: JSONDecoder { get }
    
    func data(for request: HTTPRequest, progress: RequestProgress?) async throws -> LLMResponse
    func upload(for request: HTTPRequest, fromFile fileURL: URL, progress: RequestProgress?) async throws -> LLMResponse
    func upload(for request: HTTPRequest, from fields: [LLMMultipartField]) async throws -> LLMResponse
    func upload(for request: HTTPRequest, from bodyData: Data) async throws -> LLMResponse
    func serverSendEvent(for request: HTTPRequest, from bodyData: Data, failure: (_ response: LLMResponse) async throws -> Void) async throws -> AsyncThrowingStream<Data, Error>
}

public extension LLMClientProtocol {
    
    func send(method: HTTPRequest.Method,
              headers: [HTTPField.Name: String] = [:],
              url: URL?,
              model: Encodable? = nil,
              encoder: JSONEncoder = .shared) async throws -> LLMResponse {
        guard let url = url else {
            throw URLError(.badURL)
        }
        var fields = HTTPFields()
        for (key, value) in headers {
            fields[key] = value
        }
        
        if fields[.contentType] == nil {
            fields[.contentType] = "application/json; charset=utf-8"
        }
        
        let request = HTTPRequest(method: method, url: url, headerFields: fields)
        if let model = model {
            return try await upload(for: request, from: encoder.encode(model))
        } else {
            return try await data(for: request)
        }
    }
    
    func data(for request: HTTPRequest) async throws -> LLMResponse {
        try await data(for: request, progress: nil)
    }
    
    func upload(for request: HTTPRequest, fromFile fileURL: URL, progress: RequestProgress?) async throws -> LLMResponse {
        assertionFailure()
        fatalError()
    }
    
}

public extension LLMClientProtocol {

    var encoder: JSONEncoder { .init() }
    var decoder: JSONDecoder { .init() }
    
    func encode(_ type: Encodable) throws -> Data {
       try encoder.encode(type)
    }
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
       try decoder.decode(type, from: data)
    }
    
    func decode<T: Decodable>(_ data: Data) throws -> T {
       try decoder.decode(T.self, from: data)
    }
    
    func decode<T: Decodable>(_ type: T.Type, from response: LLMResponse) throws -> T {
        try decoder.decode(type, from: response.data)
    }
    
    func decode<T: Decodable>(_ response: LLMResponse) throws -> T {
        try decoder.decode(T.self, from: response.data)
    }
    
}

public extension LLMClientProtocol {

    func add(queries: [String: String], to request: HTTPRequest) -> HTTPRequest {
        var request = request
        if !queries.isEmpty {
            if request.path?.contains("?") == false {
                request.path?.append("?")
            }
            
            request.path?.append(queries
                .compactMapValues({ $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) })
                .map({ "\($0.key)=\($0.value)" })
                .joined(separator: "&"))
        }
        return request
    }

    func request(of serivce: LLMSerivce, path: String) -> HTTPRequest {
        var request = HTTPRequest(url: .init(string: serivce.host.rawValue)!)
        var path = path
        if !path.hasPrefix("/") {
            path = "/\(path)"
        }
        request.path = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        request.headerFields = serivce.edit(headerFields: request.headerFields)
        return request
    }
    
}
