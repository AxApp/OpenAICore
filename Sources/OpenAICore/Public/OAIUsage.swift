//
//  File.swift
//  
//
//  Created by linhey on 2023/6/30.
//

import Foundation

public struct OAIUsage: Codable {
    
    public var prompt_tokens: Int
    public var completion_tokens: Int?
    public var total_tokens: Int
    
    public init(prompt_tokens: Int = 0,
                completion_tokens: Int? = nil,
                total_tokens: Int = 0) {
        self.prompt_tokens = prompt_tokens
        self.completion_tokens = completion_tokens
        self.total_tokens = total_tokens
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
