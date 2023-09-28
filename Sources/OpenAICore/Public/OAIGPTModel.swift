//
//  File.swift
//
//
//  Created by Sergii Kryvoblotskyi on 12/19/22.
//

import Foundation

public struct OAIGPTModel: Equatable, Codable, Hashable {
    
    public let name: String
    public let description: String
    public let token: Int
    public let date: Date
    
    public init(name: String, description: String, token: Int, date: Date) {
        self.name = name
        self.description = description
        self.token = token
        self.date = date
    }
    
}

public extension OAIGPTModel {
    
    static let all: [OAIGPTModel] = GPT35Turbos + GPT4s
    
    static func model(by name: String?) -> OAIGPTModel? {
        guard let name = name else { return nil }
        return all.first(where: { $0.name == name })
    }
    
}

// GPT4
public extension OAIGPTModel {
    
    static let GPT4s: [OAIGPTModel] = [.gpt4, .gpt4_32k]
    
    static let gpt4 = OAIGPTModel(name: "gpt-4",
                                  description: "More capable than any GPT-3.5 model, able to do more complex tasks, and optimized for chat. Will be updated with our latest model iteration 2 weeks after it is released.",
                                  token: 8192,
                                  date: Date(timeIntervalSince1970: 1630444800))
    
    static let gpt4_0613 = OAIGPTModel(name: "gpt-4-0613",
                                       description: "Snapshot of from June 13th 2023 with function calling data. Unlike , this model will not receive updates, and will be deprecated 3 months after a new version is released.gpt-4gpt-4",
                                       token: 8192,
                                       date: Date(timeIntervalSince1970: 1630444800))
    
    static let gpt4_32k = OAIGPTModel(name: "gpt-4-32k",
                                      description: "Same capabilities as the standard mode but with 4x the context length. Will be updated with our latest model iteration.gpt-4",
                                      token: 32768,
                                      date: Date(timeIntervalSince1970: 1630444800))
    
    static let gpt4_32k_0613 = OAIGPTModel(name: "gpt-4-32k-0613",
                                           description: "Snapshot of from June 13th 2023. Unlike , this model will not receive updates, and will be deprecated 3 months after a new version is released.gpt-4-32gpt-4-32k",
                                           token: 32768,
                                           date: Date(timeIntervalSince1970: 1630444800))
    
    /// Legacy
    static let gpt4_0314 = OAIGPTModel(name: "gpt-4-0314",
                                       description: "Snapshot of from March 14th 2023 with function calling data. Unlike , this model will not receive updates, and will be deprecated on June 13th 2024 at the earliest.gpt-4gpt-4",
                                       token: 8192,
                                       date: Date(timeIntervalSince1970: 1630444800))
    
    /// Legacy
    static let gpt4_32k_0314 = OAIGPTModel(name: "gpt-4-32k-0314",
                                           description: "Snapshot of from March 14th 2023. Unlike , this model will not receive updates, and will be deprecated on June 13th 2024 at the earliest.gpt-4-32gpt-4-32k",
                                           token: 32768,
                                           date: Date(timeIntervalSince1970: 1630444800))
}


// GPT 3.5
public extension OAIGPTModel {
    
    static let GPT35Turbos: [OAIGPTModel] = [.gpt35Turbo, .gpt35Turbo16K]
    // 创建示例实例
    static let gpt35Turbo = OAIGPTModel(name: "gpt-3.5-turbo",
                                        description: "Most capable GPT-3.5 model and optimized for chat at 1/10th the cost of . Will be updated with our latest model iteration 2 weeks after it is released.",
                                        token: 4097,
                                        date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    
    static let gpt35Turbo16K = OAIGPTModel(name: "gpt-3.5-turbo-16k",
                                           description: "Same capabilities as the standard model but with 4 times the context.",
                                           token: 16385,
                                           date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    
    static let gpt35Turbo_Instruct = OAIGPTModel(name: "gpt-3.5-turbo-instruct",
                                                 description: "Similar capabilities as but compatible with legacy Completions endpoint and not Chat Completions.",
                                                 token: 4097,
                                                 date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    
    static let gpt35Turbo_0613 = OAIGPTModel(name: "gpt-3.5-turbo-0613",
                                             description: "Snapshot of from June 13th 2023 with function calling data. Unlike , this model will not receive updates, and will be deprecated 3 months after a new version is released.",
                                             token: 4097,
                                             date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    
    static let gpt35Turbo_16k_0613 = OAIGPTModel(name: "gpt-3.5-turbo-16k-0613",
                                                 description: "Snapshot of from June 13th 2023. Unlike , this model will not receive updates, and will be deprecated 3 months after a new version is released.",
                                                 token: 16385,
                                                 date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    /// Legacy
    static let gpt35Turbo_0301 = OAIGPTModel(name: "gpt-3.5-turbo-0301",
                                             description: "Snapshot of from March 1st 2023. Unlike , this model will not receive updates, and will be deprecated on June 13th 2024 at the earliest.",
                                             token: 4097,
                                             date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    /// Legacy
    
    static let text_davinci_003 = OAIGPTModel(name: "text-davinci-003",
                                              description: "Can do any language task with better quality, longer output, and consistent instruction-following than the curie, babbage, or ada models. Also supports some additional features such as inserting text.",
                                              token: 4097,
                                              date: Date(timeIntervalSince1970: 1622505600)) // Jun 1, 2021
    /// Legacy
    
    static let text_davinci_002 = OAIGPTModel(name: "text-davinci-002",
                                              description: "Similar capabilities to but trained with supervised fine-tuning instead of reinforcement learningtext-davinci-003",
                                              token: 4097,
                                              date: Date(timeIntervalSince1970: 1622505600)) // Jun 1, 2021
    /// Legacy
    static let code_davinci_002 = OAIGPTModel(name: "code-davinci-002",
                                              description: "Optimized for code-completion tasks",
                                              token: 8001,
                                              date: Date(timeIntervalSince1970: 1622505600)) // Jun 1, 2021
    
    
}
