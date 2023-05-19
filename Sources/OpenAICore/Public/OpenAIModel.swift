//
//  File.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 12/19/22.
//

import Foundation

public struct OpenAIModel {
    
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

public extension OpenAIModel {
    
    static let all: [OpenAIModel] = allGPT4 + allGPT35

    static func model(by name: String?) -> OpenAIModel? {
        guard let name = name else { return nil }
        return all.first(where: { $0.name == name })
    }
    
}

// GPT4
public extension OpenAIModel {
    
    static let allGPT4: [OpenAIModel] = [.gpt4, .gpt40314, .gpt432k, .gpt432k0314]
    
    static let gpt4 = OpenAIModel(name: "gpt-4",
                                  description: "More capable than any GPT-3.5 model, able to do more complex tasks, and optimized for chat. Will be updated with our latest model iteration.",
                                  token: 8192,
                                  date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    
    static let gpt40314 = OpenAIModel(name: "gpt-4-0314",
                                      description: "Snapshot of from March 14th 2023. Unlike , this model will not receive updates, and will only be supported for a three month period ending on June 14th 2023.gpt-4gpt-4",
                                      token: 8192,
                                      date: Date(timeIntervalSince1970: 1676256000)) // Mar 14, 2023
    
    static let gpt432k = OpenAIModel(name: "gpt-4-32k",
                                     description: "Same capabilities as the base mode but with 4x the context length. Will be updated with our latest model iteration.gpt-4",
                                     token: 32768,
                                     date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    
    static let gpt432k0314 = OpenAIModel(name: "gpt-4-32k-0314",
                                         description: "Snapshot of from March 14th 2023. Unlike , this model will not receive updates, and will only be supported for a three month period ending on June 14th 2023.gpt-4-32gpt-4-32k",
                                         token: 32768,
                                         date: Date(timeIntervalSince1970: 1676256000)) // Mar 14, 2023
    
}


// GPT 3.5
public extension OpenAIModel {
    
    static let allGPT35: [OpenAIModel] = [.gpt35Turbo,
                                          .gpt35Turbo0301,
                                          .textDavinci003,
                                          .textDavinci002,
                                          .codeDavinci002]
    
    static let gpt35Turbo = OpenAIModel(name: "gpt-3.5-turbo",
                                        description: "Most capable GPT-3.5 model and optimized for chat at 1/10th the cost of . Will be updated with our latest model iteration.text-davinci-003",
                                        token: 4096,
                                        date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    
    static let gpt35Turbo0301 = OpenAIModel(name: "gpt-3.5-turbo-0301",
                                            description: "Snapshot of from March 1st 2023. Unlike , this model will not receive updates, and will only be supported for a three month period ending on June 1st 2023.gpt-3.5-turbogpt-3.5-turbo",
                                            token: 4096,
                                            date: Date(timeIntervalSince1970: 1630444800)) // Sep 1, 2021
    
    static let textDavinci003 = OpenAIModel(name: "text-davinci-003",
                                            description: "Can do any language task with better quality, longer output, and consistent instruction-following than the curie, babbage, or ada models. Also supports inserting completions within text.",
                                            token: 4097,
                                            date: Date(timeIntervalSince1970: 1625097600)) // Jun 30, 2021
    
    static let textDavinci002 = OpenAIModel(name: "text-davinci-002",
                                            description: "Similar capabilities to but trained with supervised fine-tuning instead of reinforcement learningtext-davinci-003",
                                            token: 4097,
                                            date: Date(timeIntervalSince1970: 1625097600)) // Jun 30, 2021
    
    static let codeDavinci002 = OpenAIModel(name: "code-davinci-002",
                                            description: "Optimized for code-completion tasks",
                                            token: 8001,
                                            date: Date(timeIntervalSince1970: 1625097600)) // Jun 30, 2021
    
}
