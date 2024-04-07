//
//  File.swift
//  
//
//  Created by linhey on 2024/4/6.
//

import Foundation
import AnyCodable
import Tiktoken

public struct LLMDocument: Codable {
    
    public typealias Metadata = [String: AnyCodable]
    public var content: String
    public var metadata: Metadata
    public init(content: String, metadata: Metadata) {
        self.content = content
        self.metadata = metadata
    }
}

public extension LLMDocument {
    
    func tiktoken(_ name: Tiktoken.EncodeName) async throws -> Int {
        try await Tiktoken.shared.getEncoding(name)?.encode(value: content).count ?? 0
    }
    
}
