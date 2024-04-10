//
//  File.swift
//
//
//  Created by linhey on 2024/4/10.
//

import Foundation
import Crypto
import Tiktoken

public protocol LLMTextNode {
    var text: String { get }
}

public extension LLMTextNode {
    
    func tiktoken(_ name: Tiktoken.EncodeName) async throws -> Int {
        try await Tiktoken.shared.getEncoding(name)?.encode(value: text).count ?? 0
    }
    
    static func hash(_ text: String, _ hasher: any HashFunction.Type = SHA256.self) -> String? {
        guard let data = text.data(using: .utf8) else {
            return nil
        }
        return hasher.hash(data: data)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
    
    func hash(_ hasher: any HashFunction.Type = SHA256.self) -> String? {
        Self.hash(text, hasher)
    }
    
}
