//
//  File.swift
//  
//
//  Created by linhey on 2023/11/17.
//

import Foundation
import STJSON

public struct OAIAssistant: Codable {
    
    public let id: String
    public let object: String
    public let createdAt: Int
    public var name: String?
    public var description: String?
    public let model: String
    public var instructions: String?
    public var tools: [ToolType]
    public var fileIds: [String]
    public var metadata: [String: String]

    public enum ToolType: String, Codable {
        case code_interpreter
        case retrieval
        case function
    }
    
}

public struct OAIAssistantAPIs {
    
    public let client: LLMClientProtocol
    public let serivce: OAISerivce
    
    public init(client: LLMClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }
    
}
