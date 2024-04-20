//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation
import HTTPTypes

private extension HTTPField.Name {
    static let organization = Self("OpenAI-Organization")!
}

public struct OAISerivce: LLMSerivce, Codable, Equatable {
    
    public var token: String
    public var organization: String
    public var host: LLMHost
    
    public init(token: String,
                organization: String = "",
                host: LLMHost = .openAI) {
        self.token = token
        self.organization = organization
        self.host = host
    }
    
    public func edit(headerFields: HTTPFields) -> HTTPFields {
        var headerFields = headerFields
        if !organization.isEmpty {
            headerFields[.organization] = organization
        }
        headerFields[.contentType] = "application/json"
        headerFields[.authorization] = "Bearer \(token)"
        return headerFields
    }
}
