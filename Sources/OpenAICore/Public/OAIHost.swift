//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation


public struct OAIHost: RawRepresentable, Codable, Equatable {
    
    public static let openAI      = OAIHost(rawValue: "https://api.openai.com")
    public static let moonshot    = OAIHost(rawValue: "https://api.moonshot.cn")
    public static let baidu_fanyi = OAIHost(rawValue: "https://fanyi-api.baidu.com")

    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init?(_ rawValue: String?) {
        guard let rawValue = rawValue else { return nil }
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
}
