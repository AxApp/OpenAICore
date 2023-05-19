//
//  File.swift
//  
//
//  Created by linhey on 2023/3/24.
//

import Foundation

public struct OAIErrorResponse: Codable {
    public let error: OAIError
}

public struct OAIError: Codable, LocalizedError {
    
    public static let invalidURL = OAIError(kind: .invalidURL)
    public static let emptyData  = OAIError(kind: .emptyData)
    
    
    public enum Kind: String, Codable {
        case invalid_request_error
        case server_error
        
        /// custom error
        case invalidURL
        case emptyData
        case unknown
    }
    
    public let message: String
    public let type: String
    public let param: String?
    public let code: String?
    
    public var kind: Kind { .init(rawValue: type) ?? .unknown }
    public var errorDescription: String? { message }

    public init(kind: Kind = .unknown, message: String? = nil, param: String? = nil, code: String? = nil) {
        self.message = message ?? kind.rawValue
        self.type = kind.rawValue
        self.param = param
        self.code = code
    }
    
}
