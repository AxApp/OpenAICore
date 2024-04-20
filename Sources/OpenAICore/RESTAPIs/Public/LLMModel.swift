//
//  File.swift
//
//
//  Created by Sergii Kryvoblotskyi on 12/19/22.
//

import Foundation

public struct LLMModelOrganization: Equatable, RawRepresentable, Codable, Hashable, ExpressibleByStringLiteral {

    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
    
}

public struct LLMModelToken: Equatable, RawRepresentable, Codable, Hashable, ExpressibleByIntegerLiteral {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}

public struct LLMModel: Equatable, Codable, Hashable {

    public let token: LLMModelToken
    public let organization: LLMModelOrganization
    public let name: String
    
    public init(token: LLMModelToken, organization: LLMModelOrganization, name: String) {
        self.token = token
        self.organization = organization
        self.name = name
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.name)
    }
    
    public enum CodingKeys: CodingKey {
        case name
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.token = 0
        self.organization = .openai
        self.name = try container.decode(String.self)
    }
    
}

public extension LLMModelOrganization {
    static let openai: LLMModelOrganization    = "openai"
    static let open_router: LLMModelOrganization = "open_router"
    static let moonshot: LLMModelOrganization  = "moonshot"
    /// 通义千问
    static let dashscope: LLMModelOrganization = "dashscope"
}

public extension LLMModelToken {
    static let x4k: LLMModelToken   = 4096
    static let x8k: LLMModelToken   = 8192
    static let x32k: LLMModelToken  = 32768
}

// GPT4
public extension LLMModel {
    
    static let GPT4s: [LLMModel] = [
        .gpt4_turbo_preview,
        .gpt4_vision_preview,
        .gpt4,
        .gpt4_32k
    ]
    
    static let gpt4_0125_preview        = LLMModel(token: 128000, organization: .openai, name: "gpt-4-0125-preview")
    static let gpt4_turbo_preview       = LLMModel(token: 128000, organization: .openai, name: "gpt-4-turbo-preview")
    static let gpt4_1106_preview        = LLMModel(token: 128000, organization: .openai, name: "gpt-4-1106-preview")
    static let gpt4_vision_preview      = LLMModel(token: 128000, organization: .openai, name: "gpt-4-vision-preview")
    static let gpt4_1106_vision_preview = LLMModel(token: 128000, organization: .openai, name: "gpt-4-1106-vision-preview")
    static let gpt4                     = LLMModel(token: .x8k,   organization: .openai, name: "gpt-4")
    static let gpt4_0613                = LLMModel(token: .x8k,   organization: .openai, name: "gpt-4-0613")
    static let gpt4_32k                 = LLMModel(token: .x8k,   organization: .openai, name: "gpt-4-32k")
    static let gpt4_32k_0613            = LLMModel(token: .x8k,   organization: .openai, name: "gpt-4-32k-0613")
    
}

// GPT 3.5
public extension LLMModel {
    
    static let GPT35s: [LLMModel] = [.gpt35_turbo]
    static let gpt35_turbo          = LLMModel(token: 16385, organization: .openai, name: "gpt-3.5-turbo")
    static let gpt35_turbo_0125     = LLMModel(token: 16385, organization: .openai, name: "gpt-3.5-turbo-0125")
    static let gpt35_turbo_1106     = LLMModel(token: 16385, organization: .openai, name: "gpt-3.5-turbo-1106")
    static let gpt35_turbo_instruct = LLMModel(token: .x4k,  organization: .openai, name: "gpt-3.5-turbo-instruct")
    
}

// moonshot
public extension LLMModel {
    
    static let moonshots: [LLMModel] = [.moonshot_v1_8k, .moonshot_v1_32k, .moonshot_v1_128k]
    static let moonshot_v1_8k   = LLMModel(token: .x8k,   organization: .moonshot, name: "moonshot-v1-8k")
    static let moonshot_v1_32k  = LLMModel(token: 32770,  organization: .moonshot, name: "moonshot-v1-32k")
    static let moonshot_v1_128k = LLMModel(token: 128000, organization: .moonshot, name: "moonshot-v1-128k")
    
}


// 通义千问
// https://help.aliyun.com/zh/dashscope/developer-reference/model-introduction?spm=a2c4g.11186623.0.0.1093140b93noQ5
public extension LLMModel {
    
    static let qwens: [LLMModel] = [.qwen_turbo, .qwen_plus, .qwen_max]
    static let qwenVLs: [LLMModel] = [.qwen_vl_max, .qwen_vl_plus]
    static let qwen_turbo   = LLMModel(token: 8192,   organization: .dashscope, name: "qwen-turbo")
    static let qwen_plus    = LLMModel(token: 32770,  organization: .dashscope, name: "qwen-plus")
    static let qwen_max     = LLMModel(token: 8192,   organization: .dashscope, name: "qwen-max")
    static let qwen_vl_plus = LLMModel(token: 32770,  organization: .dashscope, name: "qwen-vl-plus")
    static let qwen_vl_max  = LLMModel(token: 8192,   organization: .dashscope, name: "qwen-vl-max")
}