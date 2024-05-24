//
//  File.swift
//
//
//  Created by linhey on 2024/4/15.
//

import Foundation
import AnyCodable

/// openai: https://platform.openai.com/docs/api-reference/files
/// moonshot: https://platform.moonshot.cn/docs/api/partial#partial-mode
/// qwen: https://help.aliyun.com/zh/dashscope/developer-reference/openai-file-interface?spm=a2c4g.11186623.0.0.34465b78X2jGV3#00dd6fed5amwh
public struct OpenAICompatibilityChatCompletion {
    
    @EnumSingleValueCodable
    public enum Message: Codable {
        case text(OpenAICompatibilityChatCompletion.TextMessage)
        case moonshot(OpenAICompatibilityChatCompletion.MoonshotMessage)
        case qwen(OpenAICompatibilityChatCompletion.QwenMessage)
    }
    
    public struct TextMessage: Codable, Equatable {
        public var role: OAIChatCompletion.Role
        public var content: String
        public init(role: OAIChatCompletion.Role, content: String) {
            self.role = role
            self.content = content
        }
    }
    
    // MARK: - Main Request Structure
    public struct Parameters: Codable {

        public var messages: [Message]
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
        
        public init(messages: [Message] = [],
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
                    logit_bias: [Int : Double]? = nil) {
            self.messages = messages
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
        }
    }
    
}

public extension OpenAICompatibilityChatCompletion {
    
    enum QwenMessage: Codable {
        case vl(OAIChatCompletion.UserMessage)
    }
}


public extension OpenAICompatibilityChatCompletion {
    struct MoonshotPartialMessage: Codable {
        public var role: OAIChatCompletion.Role
        public var name: String
        public var content: String
        public var partial: Bool
        
        public init(role: OAIChatCompletion.Role, name: String = "", content: String = "", partial: Bool = true) {
            self.role = role
            self.name = name
            self.content = content
            self.partial = partial
        }
    }
    
    @EnumSingleValueCodable
    enum MoonshotMessage: Codable {
        // 在使用大模型时，有时我们希望通过预填（Prefill）部分模型回复来引导模型的输出。在 Kimi 大模型中，我们提供 Partial Mode 来实现这一功能，它可以帮助我们控制输出格式，引导输出内容，以及让模型在角色扮演场景中保持更好的一致性。您只需要在最后一个 role 为 assistant 的 messages 条目中，增加 "partial": True 即可开启 partial mode。
        case partial(OpenAICompatibilityChatCompletion.MoonshotPartialMessage)
    }
    
}

public extension OpenAICompatibilityChatCompletion {
    
    @EnumSingleValueCodable
    enum Options: Codable {
        case qwen(OpenAICompatibilityChatCompletion.QwenOptions)
    }
    
}

public extension OpenAICompatibilityChatCompletion {
    
    struct QwenOptions: Codable {
        public var stream_options: QwenStreamOptions?
        public var extra_body: QwenExtraBody?
        public init(stream_options: QwenStreamOptions? = nil,
                    extra_body: QwenExtraBody? = nil) {
            self.stream_options = stream_options
            self.extra_body = extra_body
        }
    }
    
    struct QwenStreamOptions: Codable {
        public var include_usage: Bool
        public init(include_usage: Bool = false) {
            self.include_usage = include_usage
        }
    }
    
    struct QwenExtraBody: Codable {
        public var enable_search: Bool
        public init(enable_search: Bool = false) {
            self.enable_search = enable_search
        }
    }
    
}
