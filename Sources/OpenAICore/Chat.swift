//
//  File.swift
//  
//
//  Created by linhey on 2023/3/21.
//

import Foundation

public struct OAIChat: OAIAPI {
    
    public var query: Query
    public let path: OAIPath = .chats
    
   public init(_ query: Query) {
        self.query = query
    }
    
    public struct Query: OAIAPIQuery, Codable {
        
        /// ID of the model to use. Currently, only gpt-3.5-turbo and gpt-3.5-turbo-0301 are supported.
        public var model: String
        /// The messages to generate chat completions for
        public var messages: [Chat]
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
        
        public init(model: OpenAIModel, messages: [Chat] = [], temperature: Double? = nil, top_p: Double? = nil, n: Int? = nil, stream: Bool? = nil, stop: [String]? = nil, max_tokens: Int? = nil, presence_penalty: Double? = nil, frequency_penalty: Double? = nil, logit_bias: [String : Int]? = nil, user: String? = nil) {
            self.model = model.name
            self.messages = messages
            self.temperature = temperature
            self.top_p = top_p
            self.n = n
            self.stream = stream
            self.stop = stop
            self.max_tokens = max_tokens
            self.presence_penalty = presence_penalty
            self.frequency_penalty = frequency_penalty
            self.logit_bias = logit_bias
            self.user = user
        }
        
        public init(model: String, messages: [Chat], temperature: Double? = nil, top_p: Double? = nil, n: Int? = nil, stream: Bool? = nil, stop: [String]? = nil, max_tokens: Int? = nil, presence_penalty: Double? = nil, frequency_penalty: Double? = nil, logit_bias: [String : Int]? = nil, user: String? = nil) {
            self.model = model
            self.messages = messages
            self.temperature = temperature
            self.top_p = top_p
            self.n = n
            self.stream = stream
            self.stop = stop
            self.max_tokens = max_tokens
            self.presence_penalty = presence_penalty
            self.frequency_penalty = frequency_penalty
            self.logit_bias = logit_bias
            self.user = user
        }
        
    }
    
    public struct Role: RawRepresentable, Codable, Equatable, Hashable, ExpressibleByStringLiteral {
        
        public static let user      = Role(rawValue: "user")
        public static let system    = Role(rawValue: "system")
        public static let assistant = Role(rawValue: "assistant")
        
        public var vaild: Bool {
            switch self {
            case .user, .system, .assistant:
                return true
            default:
                return false
            }
        }
        
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
    
    public struct Chat: Codable, Equatable {
        
        public var role: String
        public var content: String

        public init(role: String, content: String) {
            self.role = role
            self.content = content
        }
        
        public init(role: Role, content: String) {
            self.init(role: role.rawValue, content: content)
        }
    }
    
    public struct Response: Codable {
        
        public struct Choice: Codable {
            
            public let index: Int
            public let message: Chat
            public let finish_reason: String
            
            public init(index: Int, message: Chat, finish_reason: String) {
                self.index = index
                self.message = message
                self.finish_reason = finish_reason
            }
            
        }
        
        public struct Usage: Codable {
            
            public let prompt_tokens: Int
            public let completion_tokens: Int
            public let total_tokens: Int
            
            public init(prompt_tokens: Int, completion_tokens: Int, total_tokens: Int) {
                self.prompt_tokens = prompt_tokens
                self.completion_tokens = completion_tokens
                self.total_tokens = total_tokens
            }
            
        }
        
        public let id: String
        public let object: String
        public let created: TimeInterval
        public let model: String
        public let choices: [Choice]
        public let usage: Usage
        
        public init(id: String, object: String, created: TimeInterval, model: String, choices: [Choice], usage: Usage) {
            self.id = id
            self.object = object
            self.created = created
            self.model = model
            self.choices = choices
            self.usage = usage
        }
        
    }
    
   public struct DeltaChatResult: Codable {
        public struct Chat: Codable {
            public let role: String?
            public let content: String?
        }
        
        public struct Choice: Codable {
            public let delta: Chat?
            public var index: Int
            public var finish_reason: String?
        }
        
        public let id: String
        public let object: String
        public let created: TimeInterval
        public let model: String
        public let choices: [Choice]
    }
    
}
