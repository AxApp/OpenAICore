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
    public var host: OAIHost
    
    public init(token: String,
                organization: String = "",
                host: OAIHost? = nil) {
        self.token = token
        self.organization = organization
        self.host = host ?? .openAI
    }
    
    public func edit(headerFields: HTTPFields) -> HTTPFields {
        var headerFields = headerFields
        if !organization.isEmpty {
            headerFields[.organization] = organization
        }
        return headerFields
    }
    
    public static let none = OAISerivce(token: "")
}
