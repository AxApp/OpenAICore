//
//  File.swift
//
//
//  Created by linhey on 2023/3/21.
//

import Foundation
import STJSON
import AnyCodable

public struct OAIChatCompletion: Codable {
    
    public struct Role: RawRepresentable, Codable, Equatable, Hashable, ExpressibleByStringLiteral {
        
        public static let user      = Role(rawValue: "user")
        public static let system    = Role(rawValue: "system")
        public static let function  = Role(rawValue: "function")
        public static let assistant = Role(rawValue: "assistant")
        public static let tool      = Role(rawValue: "tool")
        
        public let rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
    }
    
    public struct Function: Codable, Equatable {
        public var name: String
        public var arguments: String
        public init(name: String, arguments: String) {
            self.name = name
            self.arguments = arguments
        }
    }
    
    public enum ToolCallType: String, Codable, Equatable {
        case function
    }
}

public extension OAIChatCompletion {
    
    enum ResponseFormatType: String, Codable {
        case text
        case json_object
    }
    
    struct ResponseFormat: Codable {
        public let type: ResponseFormatType
        public init(type: ResponseFormatType) {
            self.type = type
        }
    }
    
    enum UserMessageTextContentType: String, Codable {
        case image_url
        case text
    }
    
    struct RequestToolCall: Codable, Equatable {
        public var id: Int
        public var type: ToolCallType
        public var function: Function
        public init(id: Int, type: ToolCallType, function: Function) {
            self.id = id
            self.type = type
            self.function = function
        }
    }
    
    struct SystemMessage: Codable, Equatable {
        public var role: Role = .system
        public var name: String?
        public var content: String
        public init(name: String? = nil, content: String) {
            self.content = content
            self.name = name
        }
    }
    
    struct UserMessageTextContent: Codable, ExpressibleByStringLiteral, Equatable {
        public var type: UserMessageTextContentType = .text
        public var text: String
        
        public init(text: String) {
            self.text = text
        }
        public init(stringLiteral value: StringLiteralType) {
            self.text = value
        }
    }
    
    struct UserMessageImageURLContent: Codable, ExpressibleByStringLiteral, Equatable {
        
        public struct WrapperURL: Codable, Equatable {
            let url: String
        }
        
        public var type: UserMessageTextContentType = .image_url
        public var url: String { image_url.url }
        var image_url: WrapperURL
        
        public init(image_url: String) {
            self.image_url = .init(url: image_url)
        }
        
        public init(stringLiteral value: StringLiteralType) {
            self.image_url = .init(url: value)
        }
    }
    
    enum UserMessageContent: Codable, Equatable {
        case text(UserMessageTextContent)
        case image_url(UserMessageImageURLContent)
        
        public static func text(_ string: String) -> Self { self.text(.init(text: string)) }
        public static func image_url(_ string: String) -> Self { self.image_url(.init(image_url: string)) }
        
        struct GetType: Codable {
            var type: UserMessageTextContentType
        }
        
        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .image_url(let item):
                try item.encode(to: encoder)
            case .text(let item):
                try item.encode(to: encoder)
            }
        }
        
        public init(from decoder: any Decoder) throws {
            switch try GetType(from: decoder).type {
            case .image_url:
                self = .image_url(try UserMessageImageURLContent.init(from: decoder))
            case .text:
                self = .text(try UserMessageTextContent.init(from: decoder))
            }
        }
    }
    
    struct UserMessage: Codable, Equatable {
        
        public var role: Role
        public var name: String?
        public var content: [UserMessageContent]
        
        public init(role: Role = .user,
                    name: String? = nil,
                    content: [UserMessageContent]) {
            self.role = role
            self.content = content
            self.name = name
        }
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.role = try container.decode(Role.self, forKey: .role)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            if let string = try? container.decode(String.self, forKey: .content) {
                self.content = [.text(string)]
            } else {
                self.content = try container.decode([UserMessageContent].self, forKey: .content)
            }
        }
        
    }
    
    struct AssistantMessage: Codable, Equatable {
        public var role: Role = .assistant
        public var name: String?
        public var content: String?
        public var tool_calls: [RequestToolCall]?
        
        public init(name: String? = nil, content: String? = nil, tool_calls: [RequestToolCall]? = nil) {
            self.name = name
            self.content = content
            self.tool_calls = tool_calls
        }
    }
    
    struct ToolMessage: Codable, Equatable {
        public var role: Role = .tool
        public var content: String
        public var tool_call_id: String
        public init(role: Role, content: String, tool_call_id: String) {
            self.role = role
            self.content = content
            self.tool_call_id = tool_call_id
        }
    }
    
    enum RequestMessage: Codable, Equatable {
        
        case system(SystemMessage)
        case user(UserMessage)
        case assistant(AssistantMessage)
        case tool(ToolMessage)
        case unknown
        
        public var role: Role {
            switch self {
            case .system(let message):
                return message.role
            case .user(let message):
                return message.role
            case .assistant(let message):
                return message.role
            case .tool(let message):
                return message.role
            case .unknown:
                return ""
            }
            
        }
        
        public static func system(_ content: String) -> Self {
            .system(.init(content: content))
        }
        
        public static func assistant(_ content: String) -> Self {
            .assistant(.init(content: content))
        }
        
        public static func user(_ content: String) -> Self {
            .user(.text(content))
        }
        
        public static func user(_ content: UserMessageContent) -> Self {
            .user([content])
        }
        
        public static func user(_ content: [UserMessageContent]) -> Self {
            .user(.init(name: nil, content: content))
        }
        
        struct GetRole: Codable {
            var role: Role
        }
        
        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .system(let item):
                try item.encode(to: encoder)
            case .assistant(let item):
                try item.encode(to: encoder)
            case .user(let item):
                try item.encode(to: encoder)
            case .tool(let item):
                try item.encode(to: encoder)
            case .unknown:
                break
            }
        }
        
        public init(from decoder: any Decoder) throws {
            switch try GetRole(from: decoder).role {
            case .system:
                self = .system(try SystemMessage.init(from: decoder))
            case .assistant:
                self = .assistant(try AssistantMessage.init(from: decoder))
            case .user:
                self = .user(try UserMessage.init(from: decoder))
            case .tool:
                self = .tool(try .init(from: decoder))
            default:
                self = .unknown
            }
        }
        
    }
    
    enum RequestToolType: String, Equatable,Codable {
        case function
    }
    
    enum RequestTool: Codable, Equatable {
        
        case function(RequestFunctionTool)
        
        public static func function(_ function: RequestFunctionToolItem) -> Self {
            .function(.init(function: function))
        }
        
        struct GetType: Codable {
            var type: RequestToolType
        }
        
        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .function(let item):
                try item.encode(to: encoder)
            }
        }
        
        public init(from decoder: any Decoder) throws {
            switch try GetType(from: decoder).type {
            case .function:
                self = .function(try RequestFunctionTool.init(from: decoder))
            }
        }
    }
    
    struct RequestFunctionTool: Codable, Equatable {
        public var type: RequestToolType = .function
        public var function: RequestFunctionToolItem
        
        public init(function: RequestFunctionToolItem) {
            self.function = function
        }
    }
    
    struct RequestFunctionToolItem: Codable, Equatable {
        
        public var name: String
        public var description: String?
        public var parameters: [String: AnyCodable]
        
        public init(name: String, description: String?, parameters: [String : AnyCodable]) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
        
        public init(name: String, description: String?, parameters: String) throws {
            self.name = name
            self.description = description
            self.parameters = try JSONDecoder.decode([String: AnyCodable].self, from: parameters)
        }
    }
    
    struct ToolChoiceFunctionName: Codable, ExpressibleByStringLiteral {
        public var name: String
        public init(stringLiteral value: String) {
            self.name = value
        }
    }
    
    struct ToolChoiceFunction: Codable, ExpressibleByStringLiteral {
        var type: String = "function"
        var function: ToolChoiceFunctionName
        
        public init(stringLiteral value: String) {
            self.function = .init(stringLiteral: value)
        }
        
    }
    
    enum ToolChoice: Codable {
        case none
        case auto
        case function(ToolChoiceFunction)
        
        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .none:
                var container = encoder.singleValueContainer()
                try container.encode("none")
            case .auto:
                var container = encoder.singleValueContainer()
                try container.encode("auto")
            case .function(let item):
                try item.encode(to: encoder)
            }
        }
        
        public init(from decoder: any Decoder) throws {
            if let container = try? decoder.singleValueContainer(),
               let type = try? container.decode(String.self) {
                switch type {
                case "none":
                    self = .none
                case "auto":
                    self = .auto
                default:
                    self = .auto
                }
            } else if let item = try? ToolChoiceFunction(from: decoder) {
                self = .function(item)
            } else {
                self = .auto
            }
        }
        
    }
    
    struct Parameters: Codable {
        
        public var messages: [RequestMessage] = []
        public var model: LLMModel = .gpt35_turbo
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
        public var frequency_penalty: Double?
        ///Modify the likelihood of specified tokens appearing in the completion.
        public var logit_bias: [String: Int]?
        public var logprobs: Bool?
        public var top_logprobs: Int?
        /// The maximum number of tokens to generate in the completion.
        public var max_tokens: Int?
        public var n: Int?
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
        public var presence_penalty: Double?
        public var response_format: ResponseFormat?
        /// 此功能处于测试阶段。如果指定，我们的系统将尽最大努力确定性地进行采样，以便具有相同 和 参数的重复请求应返回相同的结果。不能保证确定性，您应该参考 response 参数来监视后端的变化。
        public var seed: Int?
        /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
        public var stop: [String]?
        /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only `server-sent events` as they become available, with the stream terminated by a data: [DONE] message.
        public var stream: Bool?
        /// ID of the model to use. Currently, only gpt-3.5-turbo and gpt-3.5-turbo-0301 are supported.
        /// The messages to generate chat completions for
        /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and  We generally recommend altering this or top_p but not both.
        public var temperature: Double?
        /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
        public var top_p: Double?
        /// How many chat completion choices to generate for each input message.
        public var tools: [RequestTool] = []
        public var tool_choice: ToolChoice?
        /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        public var user: String?
        
        public init() {}
        
        public static func new(_ build: (_ query: inout Self) -> Void) -> Self {
            var item = Self.init()
            build(&item)
            return item
        }
        
        enum CodingKeys: CodingKey {
            case messages
            case model
            case frequency_penalty
            case logit_bias
            case logprobs
            case top_logprobs
            case max_tokens
            case n
            case presence_penalty
            case response_format
            case seed
            case stop
            case stream
            case temperature
            case top_p
            case tools
            case tool_choice
            case user
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(messages, forKey: .messages)
            try container.encode(model, forKey: .model)
            try container.encodeIfPresent(frequency_penalty, forKey: .frequency_penalty)
            try container.encodeIfPresent(logit_bias, forKey: .logit_bias)
            try container.encodeIfPresent(logprobs, forKey: .logprobs)
            try container.encodeIfPresent(top_logprobs, forKey: .top_logprobs)
            try container.encodeIfPresent(max_tokens, forKey: .max_tokens)
            try container.encodeIfPresent(n, forKey: .n)
            try container.encodeIfPresent(presence_penalty, forKey: .presence_penalty)
            try container.encodeIfPresent(response_format, forKey: .response_format)
            try container.encodeIfPresent(seed, forKey: .seed)
            try container.encodeIfPresent(stop, forKey: .stop)
            try container.encodeIfPresent(stream, forKey: .stream)
            try container.encodeIfPresent(temperature, forKey: .temperature)
            try container.encodeIfPresent(top_p, forKey: .top_p)
            try container.encodeIfPresent(tools.isEmpty ? nil : tools, forKey: .tools)
            try container.encodeIfPresent(tool_choice, forKey: .tool_choice)
            try container.encodeIfPresent(user, forKey: .user)
        }
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.messages = try container.decode([RequestMessage].self, forKey: .messages)
            self.model = try container.decode(LLMModel.self, forKey: .model)
            self.frequency_penalty = try container.decodeIfPresent(Double.self, forKey: .frequency_penalty)
            self.logit_bias = try container.decodeIfPresent([String : Int].self, forKey: .logit_bias)
            self.logprobs = try container.decodeIfPresent(Bool.self, forKey: .logprobs)
            self.top_logprobs = try container.decodeIfPresent(Int.self, forKey: .top_logprobs)
            self.max_tokens = try container.decodeIfPresent(Int.self, forKey: .max_tokens)
            self.n = try container.decodeIfPresent(Int.self, forKey: .n)
            self.presence_penalty = try container.decodeIfPresent(Double.self, forKey: .presence_penalty)
            self.response_format = try container.decodeIfPresent(ResponseFormat.self, forKey: .response_format)
            self.seed = try container.decodeIfPresent(Int.self, forKey: .seed)
            self.stop = try container.decodeIfPresent([String].self, forKey: .stop)
            self.stream = try container.decodeIfPresent(Bool.self, forKey: .stream)
            self.temperature = try container.decodeIfPresent(Double.self, forKey: .temperature)
            self.top_p = try container.decodeIfPresent(Double.self, forKey: .top_p)
            self.tools = try container.decodeIfPresent([RequestTool].self, forKey: .tools) ?? []
            self.tool_choice = try container.decodeIfPresent(ToolChoice.self, forKey: .tool_choice)
            self.user = try container.decodeIfPresent(String.self, forKey: .user)
        }
    }
    
}


public extension OAIChatCompletion {
    
    enum Object: String, Codable {
        case chat_completion = "chat.completion"
        case chat_completion_chunk = "chat.completion.chunk"
    }
    
    struct ResponseMessage: Codable, Equatable {
        public var role: Role
        public var content: String?
        public var tool_calls: [ResponseToolCall]?
        public init(role: Role, content: String? = nil, tool_calls: [ResponseToolCall]? = nil) {
            self.role = role
            self.content = content
            self.tool_calls = tool_calls
        }
    }
    
    struct ResponseChunkMessage: Codable {
        public var content: String?
        public var tool_calls: [ResponseToolCall]?
        public var role: Role?
    }
    
    struct ResponseToolCall: Codable, Equatable {
        public var id: String
        public var type: ToolCallType
        public var function: Function
        public init(id: String, type: ToolCallType, function: Function) {
            self.id = id
            self.type = type
            self.function = function
        }
    }
    
    struct FinishReason: Codable, RawRepresentable, ExpressibleByStringLiteral, Equatable {
        public static let stop: FinishReason           = "stop"
        public static let tool_calls: FinishReason     = "tool_calls"
        public static let content_filter: FinishReason = "content_filter"
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
        public init(from decoder: any Decoder) throws {
            var container = try decoder.singleValueContainer()
            rawValue = try container.decode(RawValue.self)
        }
        
    }
    
    struct ChunkChoice: Codable {
        
        
        public var index: Int
        public var delta: ResponseChunkMessage
        public var logprobs: LogProbability
        public var finish_reason: FinishReason?
        
        public init(index: Int,
                    delta: OAIChatCompletion.ResponseChunkMessage,
                    logprobs: OAIChatCompletion.LogProbability,
                    finish_reason: OAIChatCompletion.FinishReason? = nil) {
            self.index = index
            self.delta = delta
            self.logprobs = logprobs
            self.finish_reason = finish_reason
        }
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.index = try container.decode(Int.self, forKey: CodingKeys.index)
            self.delta = try container.decode(ResponseChunkMessage.self, forKey: .delta)
            self.logprobs = try container.decodeIfPresent(LogProbability.self, forKey: .logprobs) ?? .init(content: [])
            self.finish_reason = try container.decodeIfPresent(FinishReason.self, forKey: .finish_reason)
        }
    }
    
    struct Choice: Codable, Equatable {
        public var index: Int
        public var message: ResponseMessage
        public var logprobs: LogProbability?
        public var finish_reason: FinishReason?
        
        public init(index: Int,
                    message: ResponseMessage,
                    logprobs: LogProbability?,
                    finish_reason: FinishReason? = nil) {
            self.index = index
            self.message = message
            self.logprobs = logprobs
            self.finish_reason = finish_reason
        }
    }
    
    struct TopLogProbabilityContent: Codable, Equatable {
        public var token: String
        public var logprob: Float
        public var bytes: [Int]
    }
    
    struct LogProbabilityContent: Codable, Equatable {
        public var token: String
        public var logprob: Float
        public var bytes: [Int]
        public var top_logprobs: [TopLogProbabilityContent]
    }
    
    struct LogProbability: Codable, Equatable {
        var content: [LogProbabilityContent]
    }
    
    struct StreamResponse: Codable {
        public var id: String
        public var object: Object
        public var system_fingerprint: String?
        public var created: TimeInterval
        public var model: String
        public var choices: [ChunkChoice]
        public var usage: OAIUsage?
    }
    
    struct Response: Codable {
        
        public var id: String
        public var object: Object
        public var system_fingerprint: String?
        public var created: TimeInterval
        public var model: String
        public var choices: [Choice]
        public var usage: OAIUsage?
        
        public init(id: String = "",
                    object: Object = .chat_completion,
                    created: TimeInterval = .zero,
                    model: String = "",
                    system_fingerprint: String? = nil,
                    choices: [Choice] = [],
                    usage: OAIUsage? = nil) {
            self.id = id
            self.object = object
            self.created = created
            self.model = model
            self.choices = choices
            self.system_fingerprint = system_fingerprint
            self.usage = usage
        }
    }
    
}

public extension OAIChatCompletion.ResponseToolCall {
    
    var json: JSON { JSON(parseJSON: self.function.arguments) }
    
}

public extension OAIChatCompletion.Choice {
    
    var json: JSON? {
        if let content = self.message.content {
            return JSON(parseJSON: content)
        } else if let json = self.message.tool_calls?.first?.json {
            return json
        } else {
            return nil
        }
    }
    
}
