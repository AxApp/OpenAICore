//
//  File.swift
//  
//
//  Created by linhey on 2023/6/30.
//

import Foundation

public struct OAIUsage: Codable {
    
    public let prompt_tokens: Int
    public let completion_tokens: Int?
    public let total_tokens: Int
    
    public init(prompt_tokens: Int = 0,
                completion_tokens: Int? = 0,
                total_tokens: Int = 0) {
        self.prompt_tokens = prompt_tokens
        self.completion_tokens = completion_tokens
        self.total_tokens = total_tokens
    }

}
