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
    public let trainingData: String
    
    public init(name: String, description: String, token: Int, trainingData: String) {
        self.name = name
        self.description = description
        self.token = token
        self.trainingData = trainingData
    }
    
}

public extension OAIGPTModel {
    
    static let all: [OAIGPTModel] = GPT35Turbos + GPT4s
    
    static let allMap: [String: OAIGPTModel] = {
        var dict = [String: OAIGPTModel]()
        for item in all {
            dict[item.name] = item
        }
        return dict
    }()
    
    static func model(by name: String) -> OAIGPTModel {
        return allMap[name] ?? .init(name: name,
                                     description: "",
                                     token: 0,
                                     trainingData: "")
    }
    
}

// GPT4
public extension OAIGPTModel {
    
    static let GPT4s: [OAIGPTModel] = [.gpt4, .gpt4_32k, .gpt4_1106_preview, .gpt4_vision_preview]
    
    static let gpt4     = OAIGPTModel(name: "gpt-4", description: "Currently points to gpt-4-0613", token: 128000, trainingData: "Up to Sep 2021")
    static let gpt4_32k = OAIGPTModel(name: "gpt-4-32k", description: "Currently points to gpt-4-32k-0613. See", token: 8192, trainingData: "Up to Sep 2021")
    
    
    static let gpt4_1106_preview = OAIGPTModel(name: "gpt-4-1106-preview", description: "The latest GPT-4 model with improved instruction following, JSON mode, reproducible outputs, parallel function calling, and more. Returns a maximum of 4,096 output tokens. This preview model is not yet suited for production traffic.", token: 128000, trainingData: "Up to Apr 2023")
    static let gpt4_vision_preview = OAIGPTModel(name: "gpt-4-vision-preview", description: "Ability to understand images, in addition to all other GPT-4 Turbo capabilities. Returns a maximum of 4,096 output tokens. This is a preview model version and not suited yet for production traffic.", token: 128000, trainingData: "Up to Apr 2023")
    
    static let gpt4_0613 = OAIGPTModel(name: "gpt-4-0613", description: "Snapshot of gpt-4 from June 13th 2023 with improved function calling support.", token: 8192, trainingData: "Up to Sep 2021")
    static let gpt4_32k_0613 = OAIGPTModel(name: "gpt-4-32k-0613", description: "Snapshot of gpt-4-32k from June 13th 2023 with improved function calling support.", token: 32768, trainingData: "Up to Sep 2021")
    
    @available(*, deprecated, message: "Please upgrade to the newer model")
    static let gpt4_0314 = OAIGPTModel(name: "gpt-4-0314", description: "Snapshot of gpt-4 from March 14th 2023 with function calling support. This model version will be deprecated on June 13th 2024.", token: 8192, trainingData: "Up to Sep 2021")
    @available(*, deprecated, message: "Please upgrade to the newer model")
    static let gpt4_32k_0314 = OAIGPTModel(name: "gpt-4-32k-0314", description: "Snapshot of gpt-4-32k from March 14th 2023 with function calling support. This model version will be deprecated on June 13th 2024.", token: 32768, trainingData: "Up to Sep 2021")
    
}


// GPT 3.5
public extension OAIGPTModel {
    
    static let GPT35Turbos: [OAIGPTModel] = [.gpt35Turbo, .gpt35Turbo16K]
    // 创建示例实例
    static let gpt35Turbo = OAIGPTModel(name: "gpt-3.5-turbo",
                                        description: "Most capable GPT-3.5 model and optimized for chat at 1/10th the cost of . Will be updated with our latest model iteration 2 weeks after it is released.",
                                        token: 4097,
                                        trainingData: "Up to Sep 2021") // Sep 1, 2021
    
    static let gpt35Turbo16K = OAIGPTModel(name: "gpt-3.5-turbo-16k",
                                           description: "Same capabilities as the standard model but with 4 times the context.",
                                           token: 16385,
                                           trainingData: "Up to Sep 2021") // Sep 1, 2021
    
    static let gpt35Turbo_Instruct = OAIGPTModel(name: "gpt-3.5-turbo-instruct",
                                                 description: "Similar capabilities as but compatible with legacy Completions endpoint and not Chat Completions.",
                                                 token: 4097,
                                                 trainingData: "Up to Sep 2021") // Sep 1, 2021
    
    static let gpt35Turbo_0613 = OAIGPTModel(name: "gpt-3.5-turbo-0613",
                                             description: "Snapshot of from June 13th 2023 with function calling data. Unlike , this model will not receive updates, and will be deprecated 3 months after a new version is released.",
                                             token: 4097,
                                             trainingData: "Up to Sep 2021") // Sep 1, 2021
    
    static let gpt35Turbo_16k_0613 = OAIGPTModel(name: "gpt-3.5-turbo-16k-0613",
                                                 description: "Snapshot of from June 13th 2023. Unlike , this model will not receive updates, and will be deprecated 3 months after a new version is released.",
                                                 token: 16385,
                                                 trainingData: "Up to Sep 2021") // Sep 1, 2021
    /// Legacy
    static let gpt35Turbo_0301 = OAIGPTModel(name: "gpt-3.5-turbo-0301",
                                             description: "Snapshot of from March 1st 2023. Unlike , this model will not receive updates, and will be deprecated on June 13th 2024 at the earliest.",
                                             token: 4097,
                                             trainingData: "Up to Sep 2021") // Sep 1, 2021
    /// Legacy
    
    static let text_davinci_003 = OAIGPTModel(name: "text-davinci-003",
                                              description: "Can do any language task with better quality, longer output, and consistent instruction-following than the curie, babbage, or ada models. Also supports some additional features such as inserting text.",
                                              token: 4097,
                                              trainingData: "Up to Sep 2021") // Jun 1, 2021
    /// Legacy
    
    static let text_davinci_002 = OAIGPTModel(name: "text-davinci-002",
                                              description: "Similar capabilities to but trained with supervised fine-tuning instead of reinforcement learningtext-davinci-003",
                                              token: 4097,
                                              trainingData: "Up to Sep 2021") // Jun 1, 2021
    /// Legacy
    static let code_davinci_002 = OAIGPTModel(name: "code-davinci-002",
                                              description: "Optimized for code-completion tasks",
                                              token: 8001,
                                              trainingData: "Up to Sep 2021") // Jun 1, 2021
    
    
}
