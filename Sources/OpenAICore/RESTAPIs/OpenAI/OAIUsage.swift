//
//  File.swift
//  
//
//  Created by linhey on 2023/6/30.
//

import Foundation

/// https://platform.openai.com/docs/guides/prompt-caching
public struct OAIUsage: Codable, Equatable {
    
    public struct PromptTokensDetails: Codable, Equatable  {
        public var cached_tokens: Int
        public init(cached_tokens: Int) {
            self.cached_tokens = cached_tokens
        }
    }
    
    public struct CompletionTokensDetails: Codable, Equatable {
        public var reasoning_tokens: Int
        public init(reasoning_tokens: Int) {
            self.reasoning_tokens = reasoning_tokens
        }
    }
    
    public var prompt_tokens: Int
    public var completion_tokens: Int?
    public var total_tokens: Int
    public var prompt_tokens_details: PromptTokensDetails?
    public var completion_tokens_details: CompletionTokensDetails?

    public init(prompt_tokens: Int = 0,
                completion_tokens: Int? = nil,
                total_tokens: Int = 0,
                prompt_tokens_details: PromptTokensDetails? = nil,
                completion_tokens_details: CompletionTokensDetails? = nil) {
        self.prompt_tokens = prompt_tokens
        self.completion_tokens = completion_tokens
        self.total_tokens = total_tokens
        self.prompt_tokens_details = prompt_tokens_details
        self.completion_tokens_details = completion_tokens_details
    }
    
    public mutating func merge(_ usage: OAIUsage) {
        prompt_tokens += usage.prompt_tokens
        total_tokens  += usage.total_tokens
        if let completion_tokens,
           let usage_completion_tokens = usage.completion_tokens {
            self.completion_tokens = completion_tokens + usage_completion_tokens
        } else if let usage_completion_tokens = usage.completion_tokens {
            self.completion_tokens = usage_completion_tokens
        }
    }

}
