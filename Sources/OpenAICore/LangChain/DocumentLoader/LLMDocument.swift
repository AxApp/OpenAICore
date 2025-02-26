//
//  File.swift
//  
//
//  Created by linhey on 2024/4/6.
//

import Foundation
import STJSON
import Tiktoken
import Crypto

public actor LLMDocument: LLMTextNode, ExpressibleByStringLiteral {
    
    public typealias Metadata = [String: AnyCodable]
    public let text: String
    public let metadata: Metadata
    private var _hash: String?
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    public init(_ text: String, metadata: Metadata = .init()) {
        self.text = text
        self.metadata = metadata
    }
    
    public func hash(_ hasher: any HashFunction.Type = SHA256.self) async throws -> String {
        if let _hash = _hash {
            return _hash
        }
        let hash = try Self.hash(text, hasher)
        _hash = hash
        return hash
    }
    
}
