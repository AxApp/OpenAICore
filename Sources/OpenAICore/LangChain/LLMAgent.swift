//
//  File.swift
//  
//
//  Created by linhey on 2024/4/6.
//

import Foundation

public protocol LLMAgent {
    associatedtype Input
    associatedtype Output
    func run(_ input: Input) async throws -> Output
}
