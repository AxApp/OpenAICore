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
    public static let zhipuai     = LLMHost(rawValue: "https://open.bigmodel.cn")
    public static let open_router = LLMHost(rawValue: "https://openrouter.ai")
    /// https://www.volcengine.com/docs/82379/1263482
    public static let doubao      = LLMHost(rawValue: "https://ark.cn-beijing.volces.com")

    public let scheme: String?
    public let host: String?
    public let port: Int?

    public let rawValue: String
    
    public init(rawValue: String) {
        if let components = URLComponents(string: rawValue) {
            host = components.host
            port = components.port
            scheme = components.scheme
        } else {
            host = nil
            port = nil
            scheme = nil
        }
        self.rawValue = rawValue
    }
    
    public init(scheme: String? = nil, host: String? = nil, port: Int? = nil) {
        var scheme = scheme
        var host = host
        var port = port
        
        if let components = host.flatMap(URLComponents.init(string:)) {
            scheme = components.scheme ?? scheme
            host = components.host ?? host
            port = components.port ?? port
        }
        
        var rawValue = ""
        if let scheme = scheme {
            rawValue += scheme + "://"
        }
        if let host = host {
            rawValue += host
        }
        if let port = port {
            rawValue += ":\(port)"
        }
        self.scheme = scheme
        self.host = host
        self.port = port
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    public init?(_ rawValue: String?) {
        guard let rawValue = rawValue else { return nil }
        self.init(rawValue: rawValue)
    }
    
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    
}
