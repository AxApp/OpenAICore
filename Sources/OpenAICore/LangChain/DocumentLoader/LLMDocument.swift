//
//  File.swift
//  
//
//  Created by linhey on 2024/4/6.
//

import Foundation
import AnyCodable
import Tiktoken
import Crypto

public struct LLMDocument: LLMTextNode, Codable {
    public typealias Metadata = [String: AnyCodable]
    public var text: String
    public var metadata: Metadata
    public init(_ text: String, metadata: Metadata = .init()) {
        self.text = text
        self.metadata = metadata
    }
}


public struct LLMPromptTemplate: LLMTextNode, ExpressibleByStringLiteral {
    
    public let text: String
    public let hash: String
    
    public init(stringLiteral value: String) {
        self.init(text: value)
    }
    
    public init(text: String) {
        self.text = text
        self.hash = Self.hash(text) ?? ""
    }
    
}
