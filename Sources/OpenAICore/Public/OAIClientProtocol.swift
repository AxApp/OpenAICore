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

public struct OAIClientResponse {
    public let data: Data
    public let response: HTTPResponse
    public init(data: Data, response: HTTPResponse) {
        self.data = data
        self.response = response
    }
}

public protocol STJSONEncodable {
    func encode() throws -> JSON
}

public extension STJSONEncodable where Self: Codable {

    func encode() throws -> JSON {
        let data = try JSONEncoder().encode(self)
        return try JSON(data: data)
    }
    
}

public protocol OAIClientProtocol {

    var encoder: JSONEncoder { get }
    var decoder: JSONDecoder { get }
    
    func data(for request: HTTPRequest) async throws -> OAIClientResponse
    func upload(for request: HTTPRequest, from bodyData: Data) async throws -> OAIClientResponse
    func serverSendEvent(for request: HTTPRequest, from bodyData: Data, failure: (_ response: OAIClientResponse) async throws -> Void) async throws -> AsyncThrowingStream<Data, Error>
}

public extension OAIClientProtocol {

    var encoder: JSONEncoder { .init() }
    var decoder: JSONDecoder { .init() }
    
    func encode<T: Encodable>(_ type: T) throws -> Data {
       try encoder.encode(type)
    }
    
    func encode<T: STJSONEncodable>(_ type: T) throws -> Data {
        var options: JSONSerialization.WritingOptions = []
        if encoder.outputFormatting.contains(.sortedKeys) {
            options.insert(.sortedKeys)
        }
        if encoder.outputFormatting.contains(.prettyPrinted) {
            options.insert(.prettyPrinted)
        }
        if encoder.outputFormatting.contains(.withoutEscapingSlashes) {
            options.insert(.withoutEscapingSlashes)
        }
        return try type.encode().rawData(options: options)
    }
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
       try decoder.decode(type, from: data)
    }
    
    func decode<T: Decodable>(_ data: Data) throws -> T {
       try decoder.decode(T.self, from: data)
    }
    
    func decode<T: Decodable>(_ type: T.Type, from response: OAIClientResponse) throws -> T {
        try decoder.decode(type, from: response.data)
    }
    
    func decode<T: Decodable>(_ response: OAIClientResponse) throws -> T {
        try decoder.decode(T.self, from: response.data)
    }
    
}

public extension OAIClientProtocol {

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
        var request = HTTPRequest(method: .get, url: URL(string: serivce.host.rawValue) ?? URL(string: OAIHost.openAI.rawValue)!)
        var path = path
        if !path.hasPrefix("/") {
            path = "/\(path)"
        }
        request.path = path
        request.headerFields[.contentType] = "application/json"
        request.headerFields[.authorization] = "Bearer \(serivce.token)"
        request.headerFields = serivce.edit(headerFields: request.headerFields)
        return request
    }
    
}
