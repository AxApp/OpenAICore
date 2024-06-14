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
    public let input: Int?
    public let output: Int?
    
    public func limit(input: Int? = nil, output: Int? = nil) -> LLMModelToken {
        .init(self.rawValue, input: input, output: output)
    }
    
    public init(_ rawValue: Int, input: Int? = nil, output: Int? = nil) {
        self.rawValue = rawValue
        self.input = input
        self.output = output
    }
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
        self.input = nil
        self.output = nil
    }
    
    public init(integerLiteral value: Int) {
        self.init(rawValue: value)
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
    
    /// 适配豆包推理点
    public func name(_ string: String) -> LLMModel {
        .init(token: self.token, organization: self.organization, name: string)
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
    static let openai: LLMModelOrganization      = "openai"
    static let open_router: LLMModelOrganization = "open_router"
    static let moonshot: LLMModelOrganization    = "moonshot"
    static let zhipuai: LLMModelOrganization     = "zhipuai"
    /// 通义千问
    static let dashscope: LLMModelOrganization   = "dashscope"
    /// 字节跳动
    static let bytedance: LLMModelOrganization   = "bytedance"
}

public extension LLMModelToken {
    static let x4k: LLMModelToken   = 4096
    static let x8k: LLMModelToken   = 8192
    static let x16k: LLMModelToken  = 16385
    static let x32k: LLMModelToken  = 32768
    static let x128k: LLMModelToken = 128000
}

// GPT4
public extension LLMModel {
    
    static let GPT4Os: [LLMModel] = [
        .gpt4o,
        .gpt4o_2024_05_13
    ]
    
    static let GPT4s: [LLMModel] = [
        .gpt4_turbo,
        .gpt4_turbo_2024_04_09
    ]
    
    static let gpt4o = LLMModel(token: .x128k, organization: .openai, name: "gpt-4o")
    static let gpt4o_2024_05_13 = LLMModel(token: .x128k, organization: .openai, name: "gpt-4o-2024-05-13")
    
    static let gpt4_turbo               = LLMModel(token: .x128k, organization: .openai, name: "gpt-4-turbo")
    static let gpt4_turbo_2024_04_09    = LLMModel(token: .x128k, organization: .openai, name: "gpt-4-turbo-2024-04-09")
    
    static let gpt4_turbo_preview       = LLMModel(token: .x128k, organization: .openai, name: "gpt-4-turbo-preview")
    static let gpt4_0125_preview        = LLMModel(token: .x128k, organization: .openai, name: "gpt-4-0125-preview")
    static let gpt4_1106_preview        = LLMModel(token: .x128k, organization: .openai, name: "gpt-4-1106-preview")
    static let gpt4_vision_preview      = LLMModel(token: .x128k, organization: .openai, name: "gpt-4-vision-preview")
    static let gpt4_1106_vision_preview = LLMModel(token: .x128k, organization: .openai, name: "gpt-4-1106-vision-preview")
    
    static let gpt4                     = LLMModel(token: .x8k,   organization: .openai, name: "gpt-4")
    static let gpt4_0613                = LLMModel(token: .x8k,   organization: .openai, name: "gpt-4-0613")
    static let gpt4_32k                 = LLMModel(token: .x8k,   organization: .openai, name: "gpt-4-32k")
    static let gpt4_32k_0613            = LLMModel(token: .x8k,   organization: .openai, name: "gpt-4-32k-0613")
    
}

// GPT 3.5
public extension LLMModel {
    
    static let GPT35s: [LLMModel] = [.gpt35_turbo]
    static let gpt35_turbo          = LLMModel(token: .x16k, organization: .openai, name: "gpt-3.5-turbo")
    static let gpt35_turbo_0125     = LLMModel(token: .x16k, organization: .openai, name: "gpt-3.5-turbo-0125")
    static let gpt35_turbo_1106     = LLMModel(token: .x16k, organization: .openai, name: "gpt-3.5-turbo-1106")
    static let gpt35_turbo_instruct = LLMModel(token: .x4k,  organization: .openai, name: "gpt-3.5-turbo-instruct")
    
}

// moonshot
public extension LLMModel {
    
    static let moonshots: [LLMModel] = [.moonshot_v1_8k, .moonshot_v1_32k, .moonshot_v1_128k]
    static let moonshot_v1_8k   = LLMModel(token: .x8k,   organization: .moonshot, name: "moonshot-v1-8k")
    static let moonshot_v1_32k  = LLMModel(token: .x32k,  organization: .moonshot, name: "moonshot-v1-32k")
    static let moonshot_v1_128k = LLMModel(token: .x128k, organization: .moonshot, name: "moonshot-v1-128k")
    
}


//https://www.volcengine.com/docs/82379/1263482
public extension LLMModel {
    
    static let doubaos: [LLMModel] = [
        .doubao_pro_4k,
        .doubao_pro_32k,
        .doubao_pro_128k,
        .doubao_lite_4k,
        .doubao_lite_32k,
        .doubao_lite_128k
    ]
    static let doubao_pro_4k    = LLMModel(token: .x4k,   organization: .bytedance, name: "Doubao-pro-4k")
    static let doubao_pro_32k   = LLMModel(token: .x32k,  organization: .bytedance, name: "Doubao-pro-32k")
    static let doubao_pro_128k  = LLMModel(token: .x128k, organization: .bytedance, name: "Doubao-pro-128k")
    static let doubao_lite_4k   = LLMModel(token: .x4k,   organization: .bytedance, name: "Doubao-lite-4k")
    static let doubao_lite_32k  = LLMModel(token: .x32k,  organization: .bytedance, name: "Doubao-lite-32k")
    static let doubao_lite_128k = LLMModel(token: .x128k, organization: .bytedance, name: "Doubao-lite-128k")
    
}

// https://open.bigmodel.cn/dev/api#http_auth
public extension LLMModel {
    
    static let glms: [LLMModel] = [.glm_4_0520, .glm_4, glm_4_air, glm_4_airX, glm_4_flash, glm_4v, glm_3_turbo]
    static let glm_4_0520  = LLMModel(token: .x128k, organization: .zhipuai, name: "GLM-4-0520")
    static let glm_4       = LLMModel(token: .x128k, organization: .zhipuai, name: "GLM-4")
    static let glm_4_air   = LLMModel(token: .x128k, organization: .zhipuai, name: "GLM-4-Air")
    static let glm_4_airX  = LLMModel(token: .x128k, organization: .zhipuai, name: "GLM-4-AirX")
    static let glm_4_flash = LLMModel(token: .x128k, organization: .zhipuai, name: "GLM-4-Flash")
    static let glm_4v      = LLMModel(token: 2_000,  organization: .zhipuai, name: "GLM-4V")
    static let glm_3_turbo = LLMModel(token: .x128k, organization: .zhipuai, name: "GLM-3-Turbo")
    
}


// 通义千问
// https://help.aliyun.com/zh/dashscope/developer-reference/model-introduction?spm=a2c4g.11186623.0.0.1093140b93noQ5
public extension LLMModel {
    
    static let qwens: [LLMModel] = [.qwen_turbo, .qwen_plus, .qwen_max, .qwen_max_longcontext, .qwen_long]
    static let qwen2s: [LLMModel] = [
        .qwen2_57b_a14b_instruct,
        .qwen2_72b_instruct,
        .qwen2_7b_instruct,
        .qwen2_1_5b_instruct,
        .qwen2_0_5b_instruct
    ]
    static let qwenVLs: [LLMModel] = [.qwen_vl_max, .qwen_vl_plus]
    
    /// https://help.aliyun.com/zh/dashscope/developer-reference/api-details?spm=a2c4g.11186623.0.0.3edee0f6lSCW6E
    static let qwen_turbo = LLMModel(token: .init(rawValue: 8_000).limit(input: 6_000, output: 2_000),
                                     organization: .dashscope,
                                     name: "qwen-turbo")
    static let qwen_plus  = LLMModel(token: .init(rawValue: 32_000).limit(input: 30_000, output: 2_000),
                                     organization: .dashscope,
                                     name: "qwen-plus")
    static let qwen_long  = LLMModel(token: .init(rawValue: 10_000_000).limit(output: 2_000),
                                     organization: .dashscope,
                                     name: "qwen-long")
    static let qwen_max   = LLMModel(token: qwen_turbo.token,
                                     organization: .dashscope,
                                     name: "qwen-max")
    static let qwen_max_longcontext = LLMModel(token: .init(rawValue: 30_000).limit(input: 28_000, output: 2_000),
                                               organization: .dashscope,
                                               name: "qwen-max-longcontext")
    static let qwen2_72b_instruct      = LLMModel(token: .x128k.limit(input: 128_000, output: 6_144),
                                                  organization: .dashscope,
                                                  name: "qwen2-72b-instruct")
    static let qwen2_57b_a14b_instruct = LLMModel(token: .x32k.limit(input: 30_720, output: 6_144),
                                                  organization: .dashscope,
                                                  name: "qwen2-57b-a14b-instruct")
    static let qwen2_7b_instruct       = LLMModel(token: qwen2_57b_a14b_instruct.token,
                                                  organization: .dashscope,
                                                  name: "qwen2-7b-instruct")
    static let qwen2_1_5b_instruct     = LLMModel(token: .x32k.limit(input: 30_720, output: 6_144),
                                                  organization: .dashscope,
                                                  name: "qwen2-1.5b-instruct")
    static let qwen2_0_5b_instruct     = LLMModel(token: qwen2_1_5b_instruct.token,
                                                  organization: .dashscope,
                                                  name: "qwen2-0.5b-instruct")
    
    
    static let qwen_vl_plus = LLMModel(token: .x32k,  organization: .dashscope, name: "qwen-vl-plus")
    static let qwen_vl_max  = LLMModel(token: .x8k,   organization: .dashscope, name: "qwen-vl-max")
}
