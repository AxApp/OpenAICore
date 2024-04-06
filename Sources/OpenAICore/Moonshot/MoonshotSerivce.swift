//
//  File.swift
//  
//
//  Created by linhey on 2024/4/4.
//

import Foundation

/// https://platform.moonshot.cn/docs/api-reference#%E5%9F%BA%E6%9C%AC%E4%BF%A1%E6%81%AF
public struct MoonshotSerivce: LLMSerivce, Codable, Equatable {
    
    public var token: String
    public var host: OAIHost
    
    public init(token: String, host: OAIHost? = nil) {
        self.token = token
        self.host = host ?? .moonshot
    }
}

