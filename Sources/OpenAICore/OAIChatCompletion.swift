//
//  File.swift
//
//
//  Created by linhey on 2023/3/21.
//

import Foundation
import STJSON

public struct OAIChatCompletion: Codable {
    
    public struct Function: OAIAPIQuery, Equatable, Hashable {
        
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
    
    public struct FunctionCall: Codable, Equatable, Hashable {
        public var name: String
        public var arguments: String
        
        public init(name: String, arguments: String) {
            self.name = name
            self.arguments = arguments
        }
    }
    
    public struct Role: RawRepresentable, Codable, Equatable, Hashable, ExpressibleByStringLiteral {
        
        public static let user      = Role(rawValue: "user")
        public static let system    = Role(rawValue: "system")
        public static let function  = Role(rawValue: "function")
        public static let assistant = Role(rawValue: "assistant")
        
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
    
    public struct Message: Codable, Equatable, OAIAPIQuery {
        
        public var role: String
        public var content: String
        public var function_call: FunctionCall?
        
        public init(role: String, content: String, function_call: FunctionCall? = nil) {
            self.role = role
            self.content = content
            self.function_call = function_call
        }
        
        public init(role: Role, content: String, function_call: FunctionCall? = nil) {
            self.init(role: role.rawValue, content: content, function_call: function_call)
        }
        
        public enum CodingKeys: CodingKey {
            case role
            case content
            case function_call
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.role          = try container.decodeIfPresent(String.self, forKey: .role) ?? ""
            self.content       = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
            self.function_call = try container.decodeIfPresent(FunctionCall.self, forKey: .function_call)
            
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.role, forKey: .role)
            try container.encodeIfPresent(self.content, forKey: .content)
            try container.encodeIfPresent(self.function_call, forKey: .function_call)
        }
        
        
    }
    
    public enum FinishReason: RawRepresentable, Codable {
        case none
        case stop
        case function_call
        case other(String)
        
        public var rawValue: String {
            switch self {
            case .none:
                return ""
            case .stop:
                return "stop"
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
            case "stop":
                self = .stop
            case "function_call":
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
        self.usage = usage
    }
    
}


public struct OAIChatCompletionAPIs {
    
    public let client: OAIClientProtocol
    public let serivce: OAISerivce
    
    public init(client: OAIClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }
    
    public struct CreateParameter: STJSONEncodable {
        
        public enum FunctionCall: OAIAPIQuery, Equatable, Hashable {
            
            case none
            case auto
            case function(String)
            
            public init?(from json: JSON) {
                if let value = json.string {
                    switch value {
                    case "auto": self = .auto
                    case "none": self = .none
                    default: return nil
                    }
                } else if let value = json.dictionary?["name"]?.string {
                    self = .function(value)
                } else {
                    return nil
                }
            }
            
            public func serialize() throws -> JSON {
                switch self {
                case .auto:
                    return .init("auto")
                case .none:
                    return .init("none")
                case .function(let name):
                    return .init(["name": name])
                }
            }
        }
        
        /// ID of the model to use. Currently, only gpt-3.5-turbo and gpt-3.5-turbo-0301 are supported.
        public var model: OpenAIModel = .gpt35Turbo16K
        /// The messages to generate chat completions for
        public var messages: [OAIChatCompletion.Message] = []
        /// A list of functions the model may generate JSON inputs for.
        public var functions: [OAIChatCompletion.Function] = []
        /// Controls how the model responds to function calls. "none" means the model does not call a function, and responds to the end-user. "auto" means the model can pick between an end-user or calling a function. Specifying a particular function via {"name":\ "my_function"} forces the model to call that function. "none" is the default when no functions are present. "auto" is the default if functions are present.
        public var function_call: FunctionCall?
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
            dict["frequency_penalty"] = frequency_penalty
            dict["presence_penalty"] = presence_penalty
            dict["max_tokens"] = max_tokens
            dict["stop"] = stop
            dict["stream"] = stream
            dict["n"] = n
            dict["top_p"] = top_p
            dict["temperature"] = temperature
            dict["function_call"] = try function_call?.serialize()
            if !functions.isEmpty {
                dict["functions"] = try functions.map({ try $0.serialize() })
            }
            dict["messages"] = try messages.map({ try $0.serialize() })
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
        
        var completion = OAIChatCompletion(id: "",
                                           object: .chat_completion_chunk,
                                           created: .zero,
                                           model: "",
                                           choices: [],
                                           usage: .init())
        
        do {
            for try await data in data_stream {
                completion = try merge(completion: client.decode(data), to: completion)
                continuation.yield(completion)
            }
            continuation.finish()
        } catch {
            print(error)
            continuation.finish(throwing: error)
        }
        return stream
    }
    
}

public extension OAIChatCompletionAPIs {
    
    func merge(completion: OAIChatCompletion, to raw: OAIChatCompletion) -> OAIChatCompletion {
        var raw = raw
        raw.id = completion.id
        raw.object = completion.object
        raw.created = completion.created
        raw.model = completion.model
        if raw.usage == nil { raw.usage = completion.usage }
        var raw_store = [Int: OAIChatCompletion.Choice]()
        var store = [Int: OAIChatCompletion.Choice]()
        raw.choices.forEach { choice in
            raw_store[choice.index] = choice
        }
        completion.choices.forEach { choice in
            store[choice.index] = choice
        }
        
        var choices = [Int: OAIChatCompletion.Choice]()
        raw_store.forEach { (key, value) in
            var value = value
            if let delta = store[key] {
                value.finish_reason = delta.finish_reason
                if let delta_message = delta.delta {
                    value.message.content += delta_message.content
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
        
        raw.choices = choices.map(\.value).sorted(by: { $0.index < $1.index })
        return raw
    }
    
}
