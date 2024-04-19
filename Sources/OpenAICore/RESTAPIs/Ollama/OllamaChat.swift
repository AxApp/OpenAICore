//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaChat {
    
    // MARK: - Data Structures for Chat API
    public struct ChatMessage: Codable {
        public var role: OllamaMessageRole
        public var content: String
        public var images: [String]?
        public init(role: OllamaMessageRole, content: String, images: [String]? = nil) {
            self.role = role
            self.content = content
            self.images = images
        }
    }

    public struct Parameters: Codable {
        public var model: String
        public var messages: [ChatMessage]
        public var format: OllamaResponseFormat?
        public var options: ChatOptions?
        public var stream: Bool
        public var keep_alive: String?
        
        public init(model: String,
                    messages: [ChatMessage],
                    format: OllamaResponseFormat? = nil,
                    options: ChatOptions? = nil,
                    stream: Bool = false,
                    keep_alive: String? = nil) {
            self.model = model
            self.messages = messages
            self.format = format
            self.options = options
            self.stream = stream
            self.keep_alive = keep_alive
        }
    }

    public struct ChatOptions: Codable {
        public var temperature: Double?
        public var seed: Int?
        
        init(temperature: Double? = nil, seed: Int? = nil) {
            self.temperature = temperature
            self.seed = seed
        }
    }

    public struct StreamResponse: Codable {
        public var model: String
        public var created_at: String
        public var message: ChatMessage
        public var done: Bool
        public var total_duration: Int64?
        public var load_duration: Int64?
        public var prompt_eval_count: Int?
        public var prompt_eval_duration: Int64?
        public var eval_count: Int?
        public var eval_duration: Int64?
    }
    
    public struct Response: Codable {
        public var model: String
        public var created_at: String
        public var message: ChatMessage
        public var done: Bool
        public var total_duration: Int64
        public var load_duration: Int64
        public var prompt_eval_count: Int
        public var prompt_eval_duration: Int64
        public var eval_count: Int
        public var eval_duration: Int64
        
        mutating func merge(stream: StreamResponse) {
            self.model = stream.model
            self.created_at = stream.created_at
            self.done = stream.done
            self.total_duration = stream.total_duration ?? total_duration
            self.load_duration = stream.load_duration ?? total_duration
            self.prompt_eval_count = stream.prompt_eval_count ?? prompt_eval_count
            self.prompt_eval_duration = stream.prompt_eval_duration ?? prompt_eval_duration
            self.eval_count = stream.eval_count ?? eval_count
            self.eval_duration = stream.eval_duration ?? eval_duration
            self.message.role = stream.message.role
            self.message.content += stream.message.content
        }
        
        public init(model: String,
             created_at: String,
             message: ChatMessage,
             done: Bool,
             total_duration: Int64,
             load_duration: Int64,
             prompt_eval_count: Int,
             prompt_eval_duration: Int64,
             eval_count: Int,
             eval_duration: Int64) {
            self.model = model
            self.created_at = created_at
            self.message = message
            self.done = done
            self.total_duration = total_duration
            self.load_duration = load_duration
            self.prompt_eval_count = prompt_eval_count
            self.prompt_eval_duration = prompt_eval_duration
            self.eval_count = eval_count
            self.eval_duration = eval_duration
        }
    }

}
