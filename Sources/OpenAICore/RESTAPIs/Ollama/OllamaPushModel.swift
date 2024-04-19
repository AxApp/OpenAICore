//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaPushModel {
    
    public struct Parameters: Codable {
        public var name: String
        public var insecure: Bool?
        public var stream: Bool?
        public init(name: String, insecure: Bool?, stream: Bool?) {
            self.name = name
            self.insecure = insecure
            self.stream = stream
        }
    }
    
    public struct StreamResponse: Codable {
        public let status: String
        public let digest: String?
        public let total: Int?
    }
    
    public struct SimpleResponse: Codable {
        public let status: String
    }
    
    // Enum to handle multiple types of responses
    public enum Response: Codable {
        case stream([StreamResponse])
        case simple(SimpleResponse)
        
        public init(from decoder: Decoder) throws {
            if let array = try? decoder.singleValueContainer().decode([StreamResponse].self) {
                self = .stream(array)
                return
            }
            if let single = try? decoder.singleValueContainer().decode(SimpleResponse.self) {
                self = .simple(single)
                return
            }
            throw DecodingError.typeMismatch(Response.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to decode Array<StreamResponse> or SimpleResponse"))
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case .stream(let array):
                var container = encoder.singleValueContainer()
                try container.encode(array)
            case .simple(let single):
                var container = encoder.singleValueContainer()
                try container.encode(single)
            }
        }
    }
    
}
