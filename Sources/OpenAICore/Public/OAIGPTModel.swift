//
//  File.swift
//
//
//  Created by Sergii Kryvoblotskyi on 12/19/22.
//

import Foundation
/// https://platform.openai.com/docs/models/gpt-4-and-gpt-4-turbo
public struct OAIGPTModel: Equatable, Codable, Hashable {
    
    public let name: String
    public let token: Int
    public let trainingData: String
    
    public init(token: Int, trainingData: String, name: String) {
        self.name = name
        self.token = token
        self.trainingData = trainingData
    }
    
}

public extension OAIGPTModel {
    
    static let all: [OAIGPTModel] = GPT35s + GPT4s
    
    static let allMap: [String: OAIGPTModel] = {
        var dict = [String: OAIGPTModel]()
        for item in all {
            dict[item.name] = item
        }
        return dict
    }()
    
    static func model(by name: String) -> OAIGPTModel {
        return allMap[name] ?? .init(token: 0, trainingData: "", name: "")
    }
    
}

// GPT4
public extension OAIGPTModel {
    
    static let GPT4s: [OAIGPTModel] = [
        .gpt4_turbo_preview,
        .gpt4_vision_preview,
        .gpt4,
        .gpt4_32k
    ]
    
    static let gpt4_0125_preview        = OAIGPTModel(token: 128000, trainingData: "Up to Sep 2023", name: "gpt-4-0125-preview")
    static let gpt4_turbo_preview       = OAIGPTModel(token: 128000, trainingData: "Up to Sep 2023", name: "gpt-4-turbo-preview")
    static let gpt4_1106_preview        = OAIGPTModel(token: 128000, trainingData: "Up to Sep 2023", name: "gpt-4-1106-preview")
    static let gpt4_vision_preview      = OAIGPTModel(token: 128000, trainingData: "Up to Sep 2023", name: "gpt-4-vision-preview")
    static let gpt4_1106_vision_preview = OAIGPTModel(token: 128000, trainingData: "Up to Sep 2023", name: "gpt-4-1106-vision-preview")
    static let gpt4                     = OAIGPTModel(token: 8192,   trainingData: "Up to Sep 2021", name: "gpt-4")
    static let gpt4_0613                = OAIGPTModel(token: 8192,   trainingData: "Up to Sep 2021", name: "gpt-4-0613")
    static let gpt4_32k                 = OAIGPTModel(token: 8192,   trainingData: "Up to Sep 2021", name: "gpt-4-32k")
    static let gpt4_32k_0613            = OAIGPTModel(token: 8192,   trainingData: "Up to Sep 2021", name: "gpt-4-32k-0613")
    
}

// GPT 3.5
public extension OAIGPTModel {
    
    static let GPT35s: [OAIGPTModel] = [.gpt35_turbo]
    static let gpt35_turbo          = OAIGPTModel(token: 16385, trainingData: "Up to Sep 2021", name: "gpt-3.5-turbo")
    static let gpt35_turbo_0125     = OAIGPTModel(token: 16385, trainingData: "Up to Sep 2021", name: "gpt-3.5-turbo-0125")
    static let gpt35_turbo_1106     = OAIGPTModel(token: 16385, trainingData: "Up to Sep 2021", name: "gpt-3.5-turbo-1106")
    static let gpt35_turbo_instruct = OAIGPTModel(token: 4096, trainingData: "Up to Sep 2021",  name: "gpt-3.5-turbo-instruct")
    
}
