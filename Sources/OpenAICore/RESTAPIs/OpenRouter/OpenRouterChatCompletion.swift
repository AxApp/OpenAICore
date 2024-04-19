//
//  File.swift
//  
//
//  Created by linhey on 2024/4/15.
//

import Foundation
import AnyCodable

public struct OpenRouterChatCompletion {

    public enum DetailOption: String, Codable {
        case auto
    }
    
    // MARK: - Provider Preferences
    public struct ProviderPreferences: Codable {
        // Define specific provider preference properties here if needed
    }

    // MARK: - Main Request Structure
    public struct CreateParameter: Codable {
        public var messages: [OAIChatCompletion.UserMessage]?
        public var prompt: String?
        public var model: LLMModel?
        public var response_format: OAIChatCompletion.ResponseFormat?
        public var stop: [String]?
        public var stream: Bool?
        public var max_tokens: Int?
        public var temperature: Double?
        public var top_p: Double?
        public var top_k: Int?
        public var frequency_penalty: Double?
        public var presence_penalty: Double?
        public var repetition_penalty: Double?
        public var seed: Int?
        public var tools: [OAIChatCompletion.RequestFunctionTool]?
        public var tool_choice: OAIChatCompletion.ToolChoice?
        public var logit_bias: [Int: Double]?
        public var transforms: [String]?
        public var models: [LLMModel]?
        public var route: String?
        public var provider: ProviderPreferences?
        
        public init(messages: [OAIChatCompletion.UserMessage]? = nil,
                    prompt: String? = nil,
                    model: LLMModel? = nil,
                    response_format: OAIChatCompletion.ResponseFormat? = nil,
                    stop: [String]? = nil,
                    stream: Bool? = nil,
                    max_tokens: Int? = nil,
                    temperature: Double? = nil,
                    top_p: Double? = nil,
                    top_k: Int? = nil,
                    frequency_penalty: Double? = nil,
                    presence_penalty: Double? = nil,
                    repetition_penalty: Double? = nil,
                    seed: Int? = nil,
                    tools: [OAIChatCompletion.RequestFunctionTool]? = nil,
                    tool_choice: OAIChatCompletion.ToolChoice? = nil,
                    logit_bias: [Int : Double]? = nil,
                    transforms: [String]? = nil,
                    models: [LLMModel]? = nil,
                    route: String? = nil,
                    provider: ProviderPreferences? = nil) {
            self.messages = messages
            self.prompt = prompt
            self.model = model
            self.response_format = response_format
            self.stop = stop
            self.stream = stream
            self.max_tokens = max_tokens
            self.temperature = temperature
            self.top_p = top_p
            self.top_k = top_k
            self.frequency_penalty = frequency_penalty
            self.presence_penalty = presence_penalty
            self.repetition_penalty = repetition_penalty
            self.seed = seed
            self.tools = tools
            self.tool_choice = tool_choice
            self.logit_bias = logit_bias
            self.transforms = transforms
            self.models = models
            self.route = route
            self.provider = provider
        }
    }

}
