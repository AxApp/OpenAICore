//
//  File.swift
//
//
//  Created by linhey on 2023/3/21.
//

import Foundation
import STJSON

public struct OAIChatCompletion: Codable {
    
    public typealias Message = MessageItem<String>
    
    public struct FunctionCall: Codable, Equatable, Hashable {
        public var name: String
        public var arguments: String
        
        public init(name: String, arguments: String) {
            self.name = name
            self.arguments = arguments
        }
    }
    
    public struct ToolCall: Codable, Equatable {
        public let id: String
        public let type: String
        public let function: FunctionCall
        public init(id: String, type: String, function: FunctionCall) {
            self.id = id
            self.type = type
            self.function = function
        }
    }
    
    public struct MessageItem<Content: Codable & Equatable>: Codable, Equatable, STJSONEncodable {
        public var role: String
        public var content: Content?
        public var tool_calls: [ToolCall]?
        public var tool_call_id: String?
        
        public init(role: String, content: Content) {
            self.role = role
            self.content = content
        }
        
        public init(role: Role, content: Content) {
            self.init(role: role.rawValue, content: content)
        }
        
        public init(from decoder: Decoder) throws {
            let container     = try decoder.container(keyedBy: CodingKeys.self)
            self.role         = try container.decodeIfPresent(String.self, forKey: .role) ?? ""
            self.content      = try container.decodeIfPresent(Content.self, forKey: .content)
            self.tool_calls   = try container.decodeIfPresent([OAIChatCompletion.ToolCall].self, forKey: .tool_calls)
            self.tool_call_id = try container.decodeIfPresent(String.self, forKey: .tool_call_id)
        }
    }
    
    public struct Function: Equatable, Hashable {
        
        public var name: String
        public var description: String?
        public var parameters: JSON
        
        public init(name: String = "",
                    description: String? = nil,
                    parameters: String? = nil) {
            self.name = name
            self.description = description
            self.parameters = JSON(parseJSON: parameters ?? "")
        }
        
        public init(name: String = "",
                    description: String? = nil,
                    parameters: JSON) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
        
        public init(from json: JSON) {
            self.name        = json["name"].stringValue
            self.description = json["description"].string
            self.parameters  = json["parameters"]
        }
        
        public func serialize() throws -> JSON {
            var dict = [String: Any]()
            dict["name"] = name
            dict["description"] = description
            dict["parameters"] = parameters.dictionaryObject
            return .init(dict)
        }
        
    }
    
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
    
    public enum FinishReason: RawRepresentable, Codable {
        case none
        case stop
        case tool_calls
        case function_call
        case other(String)
        
        public var rawValue: String {
            switch self {
            case .none:
                return ""
            case .stop:
                return "stop"
            case .tool_calls:
                return "tool_calls"
            case .function_call:
                return "function_call"
            case .other(let value):
                return value
            }
        }
        
        public init(rawValue: String) {
            switch rawValue {
            case "":
                self = .none
            case FinishReason.stop.rawValue:
                self = .stop
            case FinishReason.tool_calls.rawValue:
                self = .tool_calls
            case FinishReason.function_call.rawValue:
                self = .function_call
            default:
                self = .other(rawValue)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self.init(rawValue: value)
        }
    }
    
    public struct Choice: Codable {
        
        public var index: Int
        public var message: Message
        public var delta: Message?
        public var finish_reason: FinishReason?
        
        public init(index: Int,
                    message: OAIChatCompletion.Message,
                    finish_reason: OAIChatCompletion.FinishReason? = nil) {
            self.index = index
            self.message = message
            self.delta = nil
            self.finish_reason = finish_reason
        }
        
        public init(index: Int,
                    delta: OAIChatCompletion.Message,
                    finish_reason: OAIChatCompletion.FinishReason? = nil) {
            self.index = index
            self.message = delta
            self.delta = delta
            self.finish_reason = finish_reason
        }
        
        enum CodingKeys: CodingKey {
            case index
            case message
            case delta
            case finish_reason
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.index, forKey: .index)
            try container.encodeIfPresent(self.message, forKey: .message)
            try container.encodeIfPresent(self.delta, forKey: .delta)
            try container.encodeIfPresent(self.finish_reason, forKey: .finish_reason)
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.index = try container.decode(Int.self, forKey: .index)
            self.message = try container.decodeIfPresent(Message.self, forKey: .message) ?? .init(role: "", content: "")
            self.delta = try container.decodeIfPresent(Message.self, forKey: .delta)
            self.finish_reason = try container.decodeIfPresent(FinishReason.self, forKey: .finish_reason)
        }
    }
    
    public enum Object: String, Codable {
        case chat_completion = "chat.completion"
        case chat_completion_chunk = "chat.completion.chunk"
    }
    
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
                choices: [Choice] = [],
                usage: OAIUsage? = nil) {
        self.id = id
        self.object = object
        self.created = created
        self.model = model
        self.choices = choices
        self.system_fingerprint = nil
        self.usage = usage
    }
    
}

public class OAIChatCompletionStreamMerge {
    
    public enum Chunk {
        case completion(OAIChatCompletion)
        case done
    }
    
    public var completion = OAIChatCompletion()
    public var chunks = [OAIChatCompletion]()

    public init(completion: OAIChatCompletion = OAIChatCompletion()) {
        self.completion = completion
    }
    
    public func chunk(of data: Data) throws -> [Chunk] {
        guard let eventString = String(data: data, encoding: .utf8) else { return [] }
        let lines = eventString.split(separator: "\n")
        var chunks = [Chunk]()
        let dataTag = "data:"
        for line in lines {
            if line == "data: [DONE]" {
                chunks.append(.done)
            } else if line.hasPrefix(dataTag), let data = String(line.dropFirst(dataTag.count)).data(using: .utf8) {
                let completion = try JSONDecoder.shared.decode(OAIChatCompletion.self, from: data)
                chunks.append(.completion(completion))
            }
        }
        return chunks
    }
    
    public func merge(_ chunks: [Chunk]) {
        for chunk in chunks {
            switch chunk {
            case .completion(let completion):
                self.chunks.append(completion)
                merge(completion)
            case .done:
                completion.usage = .init(completion_tokens: self.chunks.count)
            }
        }
    }
    
    public func merge(_ other: OAIChatCompletion) {
        completion.id      = other.id
        completion.object  = other.object
        completion.created = other.created
        completion.model   = other.model
        if completion.usage == nil { completion.usage = other.usage }
        if completion.system_fingerprint == nil { completion.system_fingerprint = other.system_fingerprint }
        var raw_store = [Int: OAIChatCompletion.Choice]()
        var store = [Int: OAIChatCompletion.Choice]()
        completion.choices.forEach { choice in
            raw_store[choice.index] = choice
        }
        other.choices.forEach { choice in
            store[choice.index] = choice
        }
        
        var choices = [Int: OAIChatCompletion.Choice]()
        raw_store.forEach { (key, value) in
            var value = value
            if let delta = store[key] {
                value.finish_reason = delta.finish_reason
                if let delta_message = delta.delta {
                    if value.message.content == nil {
                        value.message.content = delta_message.content
                    } else if let content = delta_message.content {
                        value.message.content?.append(content)
                    }
                    value.message.role = delta_message.role.isEmpty ? value.message.role : delta_message.role
                }
                store[key] = nil
            }
            choices[key] = value
        }
        raw_store.removeAll()
        
        store.forEach { (key, value) in
            var value = value
            value.message = value.delta ?? value.message
            value.delta = nil
            choices[key] = value
        }
        store.removeAll()
        
        completion.choices = choices.map(\.value).sorted(by: { $0.index < $1.index })
    }

}


public struct OAIChatCompletionAPIs {
    
    public let client: OAIClientProtocol
    public let serivce: OAISerivce
    
    public init(client: OAIClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }
    
    public enum ResponseFormat: String, Codable {
        case json
    }
    
    public struct CreateParameter: STJSONEncodable {
        
        public struct FunctionItem: Equatable, Hashable, Codable {
            public let name: String
            
            public init(name: String) {
                self.name = name
            }
        }
        
        public struct FunctionChoice: Equatable, Hashable, STJSONEncodable {
            
            public let type = "function"
            public let function: OAIChatCompletion.Function
            
            public init(function: OAIChatCompletion.Function) {
                self.function = function
            }
            
            public func encode() throws -> JSON {
                var json = JSON()
                json["type"] = .init(type)
                json["function"] = try function.serialize()
                return json
            }
            
        }
        
        public enum ToolChoice: Equatable, Hashable, STJSONEncodable {
            
            case none
            case auto
            case function(FunctionChoice)
            
            public func encode() throws -> JSON {
                switch self {
                case .none:
                    return "none"
                case .auto:
                    return "auto"
                case .function(let choice):
                    return try choice.encode()
                }
            }
            
        }
        
        public enum Tool: STJSONEncodable {
            
            case function(FunctionChoice)
        
            public init(function: OAIChatCompletion.Function) {
                self = .function(.init(function: function))
            }
            
            public func encode() throws -> JSON {
                switch self {
                case .function(let choice):
                    return try choice.encode()
                }
            }
            
        }
        
        public struct TextMessage: Codable, Equatable, ExpressibleByStringLiteral {
           public var type: String = "text"
           public var text: String
            
           public init(_ text: String) {
               self.text = text
            }
            
            public init(stringLiteral value: String) {
                self.text = value
            }
        }
        
        public struct ImageURL: Codable, Equatable {
            var url: String
            public init(url: String) {
                self.url = url
            }
        }
                
        public struct ImageURLMessage: Codable, Equatable, ExpressibleByStringLiteral {
            public var type: String = "image_url"
            public var image_url: ImageURL
            
            public init(image_url: ImageURL) {
                self.image_url = image_url
            }
            
            public init(stringLiteral value: String) {
                self.image_url = .init(url: value)
            }
        }
        
        public enum MessageChoice: Codable, Equatable {
            
            case text(TextMessage)
            case image_url(ImageURLMessage)
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .text(let value):
                    try container.encode(value)
                case .image_url(let value):
                    try container.encode(value)
                }
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let value = try? container.decode(TextMessage.self) {
                    self = .text(value)
                } else if let value = try? container.decode(ImageURLMessage.self) {
                    self = .image_url(value)
                } else {
                    throw OAIError.decode_data
                }
            }
        }
        
        public var response_format: ResponseFormat?
        /// 此功能处于测试阶段。如果指定，我们的系统将尽最大努力确定性地进行采样，以便具有相同 和 参数的重复请求应返回相同的结果。不能保证确定性，您应该参考 response 参数来监视后端的变化。
        public var seed: Int?
        public var tools: [Tool]?
        public var tool_choice: ToolChoice?
        /// ID of the model to use. Currently, only gpt-3.5-turbo and gpt-3.5-turbo-0301 are supported.
        public var model: OAIGPTModel = .gpt35Turbo16K
        /// The messages to generate chat completions for
        public var messages: [OAIChatCompletion.MessageItem<[MessageChoice]>] = []
        /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and  We generally recommend altering this or top_p but not both.
        public var temperature: Double?
        /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
        public var top_p: Double?
        /// How many chat completion choices to generate for each input message.
        public var n: Int?
        /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only `server-sent events` as they become available, with the stream terminated by a data: [DONE] message.
        public var stream: Bool?
        /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
        public var stop: [String]?
        /// The maximum number of tokens to generate in the completion.
        public var max_tokens: Int?
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
        public var presence_penalty: Double?
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
        public var frequency_penalty: Double?
        ///Modify the likelihood of specified tokens appearing in the completion.
        public var logit_bias: [String: Int]?
        /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        public var user: String?
        
        public func encode() throws -> JSON {
            var dict = [String: Any]()
            dict["logit_bias"] = logit_bias
            if let response_format {
                dict["response_format"] = ["type": response_format.rawValue]
            }
            dict["frequency_penalty"] = frequency_penalty
            dict["presence_penalty"] = presence_penalty
            dict["max_tokens"] = max_tokens
            dict["stop"] = stop
            dict["stream"] = stream
            dict["n"] = n
            dict["top_p"] = top_p
            dict["temperature"] = temperature
            dict["tool_choice"] = try tool_choice?.encode()
            dict["tools"] = try tools?.map({ try $0.encode() })
            dict["messages"] = try messages.map({ try $0.encode() })
            dict["model"] = model.name
            return .init(dict)
        }
        
        public init() {}
        
        public static func new(_ build: (_ query: inout Self) -> Void) -> Self {
            var item = Self.init()
            build(&item)
            return item
        }
    }
    
    public func create(_ parameter: CreateParameter) async throws -> OAIChatCompletion {
        var request = client.request(of: serivce, path: "v1/chat/completions")
        request.method = .post
        var parameter = parameter
        parameter.stream = false
        let request_body = try client.encode(parameter)
        let data = try await client.upload(for: request, from: request_body)
        return try client.decode(data)
    }
    
    
    public func create(stream parameter: CreateParameter) async throws -> AsyncThrowingStream<OAIChatCompletion, Error> {
        var request = client.request(of: serivce, path: "v1/chat/completions")
        request.method = .post
        var parameter = parameter
        parameter.stream = true
        let request_body = try client.encode(parameter)
        let (stream, continuation) = AsyncThrowingStream<OAIChatCompletion, Error>.makeStream()
        let data_stream = try client.stream(for: request, from: request_body)
        let streamMerge = OAIChatCompletionStreamMerge()
        
        do {
            for try await data in data_stream {
                let chunks = try streamMerge.chunk(of: data.data)
                streamMerge.merge(chunks)
                continuation.yield(streamMerge.completion)
            }
            continuation.finish()
        } catch {
            print(error)
            continuation.finish(throwing: error)
        }
        return stream
    }
    
}

public extension OAIChatCompletion {
    
    public struct CallBack {
        public let completion: OAIChatCompletion
        
        public var functions: [FunctionCall] {
            completion.choices.compactMap(\.message.tool_calls).joined().map(\.function)
        }
        
        public var contents: [String] {
            completion.choices.compactMap(\.message.content)
        }
    }
    
    var callback: CallBack { .init(completion: self) }
    
}

public extension OAIChatCompletion.FunctionCall {
    
    var json: JSON { JSON(parseJSON: arguments) }
    var data: Data { arguments.data(using: .utf8) ?? .init() }
    
}

public extension OAIChatCompletionAPIs.CreateParameter {
    
    mutating func set(singleFunction function: OAIChatCompletion.Function) {
        self.tools = [.init(function: function)]
        self.tool_choice = .function(.init(function: .init(name: function.name)))
    }
    
    mutating func append(message content: String, role: OAIChatCompletion.Role) {
        self.messages.append(.init(role: role, content: [.text(.init(content))]))
    }
    
}
