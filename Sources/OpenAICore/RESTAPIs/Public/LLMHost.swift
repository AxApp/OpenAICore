//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation

public struct LLMHost: RawRepresentable, ExpressibleByStringLiteral, Codable, Equatable {
    
    public static let openAI      = LLMHost(rawValue: "https://api.openai.com")
    public static let moonshot    = LLMHost(rawValue: "https://api.moonshot.cn")
    public static let baidu_fanyi = LLMHost(rawValue: "https://fanyi-api.baidu.com")
    public static let qwen        = LLMHost(rawValue: "https://dashscope.aliyuncs.com")
    public static let open_router = LLMHost(rawValue: "https://openrouter.ai")

    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
    
    public init?(_ rawValue: String?) {
        guard let rawValue = rawValue else { return nil }
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
}
