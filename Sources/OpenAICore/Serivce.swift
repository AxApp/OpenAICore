//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation

public struct OAISerivce: Codable, Equatable {
    
    public var token: String
    public var organization: String
    public var host: OAIHost
    
    public init(token: String, organization: String = "", host: OAIHost? = nil) {
        self.token = token
        self.organization = organization
        self.host = host ?? .openAI
    }
    
    public static let none = OAISerivce(token: "")
}
