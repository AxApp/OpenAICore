//
//  File.swift
//
//
//  Created by linhey on 2023/3/24.
//

import Foundation

public struct OAIErrorResponse: Codable {
    public let error: OAIError
    public init(error: OAIError) {
        self.error = error
    }
}

public struct OAIError: Codable, LocalizedError {
    
    public static let invalidURL = OAIError(type: .invalidURL)
    public static let emptyData  = OAIError(type: .emptyData)
    
    public struct Kind: RawRepresentable, ExpressibleByStringLiteral, Codable, Equatable {
        static let invalid_request_error = Kind(rawValue: "invalid_request_error")
        static let server_error = Kind(rawValue: "server_error")
        static let invalidURL = Kind(rawValue: "invalidURL")
        static let emptyData = Kind(rawValue: "emptyData")
        static let failedToConvertHTTPRequestToURLRequest = Kind(rawValue: "failedToConvertHTTPRequestToURLRequest")
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(RawValue.self)
        }
    }
    
    public let message: String
    public let type: Kind
    public let param: String?
    public let code: String?
    public var errorDescription: String? { message }
    
    public init(type: Kind,
                message: String? = nil,
                param: String? = nil,
                code: String? = nil) {
        self.message = message ?? type.rawValue
        self.type = type
        self.param = param
        self.code = code
    }
    
}
