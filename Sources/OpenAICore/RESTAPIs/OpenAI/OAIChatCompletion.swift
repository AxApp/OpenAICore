//
//  File.swift
//
//
//  Created by linhey on 2023/3/21.
//

import Foundation
import STJSON
import AnyCodable

public struct OAIChatCompletion: Codable, Sendable {
    
    public struct Role: RawRepresentable, Codable, Sendable, Equatable, Hashable, ExpressibleByStringLiteral {
        
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
        public var description: String?
        public var arguments: String
        public var strict: Bool?
        
        public init(name: String,
                    description: String? = nil,
                    arguments: String,
                    strict: Bool? = nil) {
            self.name = name
            self.arguments = arguments
            self.description = description
            self.strict = strict
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
        case json_schema
    }
    
    struct ResponseFormat: Codable {
        
        public struct JsonSchema: Codable, Equatable {
           
            public var name: String
            public var description: String?
            public var schema: AnyCodable?
            public var strict: Bool?

            public init(name: String,
                        description: String? = nil,
                        schema: AnyCodable,
                        strict: Bool? = nil) {
                self.name = name
                self.schema = schema
                self.description = description
                self.strict = strict
            }
        }
        
        public var type: ResponseFormatType
        public var json_schema: JsonSchema?
        
        public init(type: ResponseFormatType) {
            self.type = type
        }
        
        public static func json_object() -> ResponseFormat {
            .init(type: .json_object)
        }
        
        public static func json_schema(_ schema: JsonSchema) -> ResponseFormat {
           var item = ResponseFormat(type: .json_schema)
            item.json_schema = schema
            return item
        }
        
    }
    
    enum UserMessageTextContentType: String, Codable {
        case image_url
        case text
    }
    
    struct RequestToolCall: Codable, Equatable {
        public var id: String
        public var type: ToolCallType
        public var function: Function
        
        public init(id: String, type: ToolCallType, function: Function) {
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
    
    struct UserMessageImageURLContent: Codable, Equatable {
        
        enum Detail: String, Codable {
            case auto
            case high
            case low
        }
        
        public struct WrapperURL: Codable, Equatable {
            let url: String
            let detail: Detail?
        }
        
        public let type: UserMessageTextContentType = .image_url
        var image_url: WrapperURL
    }
    
    enum UserMessageContent: Codable, Equatable {
        case text(UserMessageTextContent)
        case image_url(UserMessageImageURLContent)
        
        public static func text(_ string: String) -> Self { self.text(.init(text: string)) }
       
        public static func image_url(_ string: String) -> Self {
            self.image_url(UserMessageImageURLContent.init(image_url: .init(url: string, detail: nil)))
        }
        public static func image_url(_ item: UserMessageImageURLContent.WrapperURL) -> Self {
            self.image_url(UserMessageImageURLContent(image_url: item))
        }
        
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
        
        public let role: Role = .assistant
        public var name: String?
        public var refusal: String?
        
        public var content: String?
        public var tool_calls: [RequestToolCall]?
        
        public init() {}
    }
    
    struct ToolMessage: Codable, Equatable {
        
        public let role: Role = .tool
        public var content: String
        public var tool_call_id: String
        public var name: String

        public init(name: String,
                    content: String,
                    tool_call_id: String) {
            self.name = name
            self.content = content
            self.tool_call_id = tool_call_id
        }
        
        public init(from call: ResponseToolCall) {
            self.name = call.function.name
            self.content = call.function.arguments
            self.tool_call_id = call.id
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
        
        public static func assistant(_ builder: (inout AssistantMessage) -> Void) -> Self {
            var message = AssistantMessage()
            builder(&message)
            return .assistant(message)
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
    
    public struct RequestToolType: RawRepresentable, Equatable, Codable, ExpressibleByStringLiteral {
        
        public static let function = RequestToolType(rawValue: "function")
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: StringLiteralType) {
            self.rawValue = value
        }
        
    }
    
    enum RequestTool: Codable, Equatable {
        
        case function(RequestFunctionTool)
        
        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .function(let item):
                try item.encode(to: encoder)
            }
        }
        
        public init(from decoder: any Decoder) throws {
            let function = try RequestFunctionTool(from: decoder)
            self = .function(function)
        }
    }
    
    struct RequestFunctionTool: Codable, Equatable {
        
        public var type: RequestToolType
        public var function: RequestFunctionToolItem
        
        public init(type: RequestToolType = .function,
                    function: RequestFunctionToolItem) {
            self.function = function
            self.type = type
        }
    }
    
    struct RequestFunctionToolItem: Codable, Equatable {
        
        public var name: String
        public var description: String?
        public var parameters: AnyCodable?
        public var strict: Bool?
        
        public init(name: String,
                    description: String? = nil,
                    parameters: AnyCodable? = nil,
                    strict: Bool? = nil) {
            self.name = name
            self.description = description
            self.parameters = parameters
            self.strict = strict
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
    
    enum Modality: String, Codable {
        case text
        case audio
    }
    
    /// https://platform.openai.com/docs/api-reference/chat/create
    struct Parameters: Codable {
        public var service_tier: String?
        public var messages: [RequestMessage] = []
        public var model: LLMModel = .gpt35_turbo
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
        public var frequency_penalty: Double?
        ///Modify the likelihood of specified tokens appearing in the completion.
        public var logit_bias: [String: Int]?
        public var logprobs: Bool?
        public var top_logprobs: Int?
        public var metadata: AnyCodable?
        public var store: Bool?
        public var max_completion_tokens: Int?
        
        public var n: Int?
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
        public var presence_penalty: Double?
        public var response_format: ResponseFormat?
        public var modalities: [Modality]?
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
        public var tools: [RequestTool]? = []
        public var tool_choice: ToolChoice?
        /// 是否在工具使用过程中启用并行函数调用。
        public var parallel_tool_calls: Bool?
        /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        public var user: String?
        
        public init() {}
        
        public static func new(_ build: (_ query: inout Self) -> Void) -> Self {
            var item = Self.init()
            build(&item)
            return item
        }
        
        public func finishEdit() -> Self {
            var item = self
            if item.tools?.isEmpty == true {
                item.tools = nil
            }
            return item
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
        public var reasoning_content: String?
        public var tool_calls: [ResponseToolCall]?
        
        public init(role: Role,
                    content: String? = nil,
                    reasoning_content: String? = nil,
                    tool_calls: [ResponseToolCall]? = nil) {
            self.role = role
            self.content = content
            self.reasoning_content = reasoning_content
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
        public var type: RequestToolType
        public var function: Function
        public init(id: String, type: RequestToolType, function: Function) {
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
            let container = try decoder.singleValueContainer()
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
        var content: [LogProbabilityContent]?
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
