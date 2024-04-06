//
//  File.swift
//  
//
//  Created by linhey on 2024/4/4.
//

import Foundation
import HTTPTypes

public protocol LLMSerivce {
    var token: String { get }
    var host: OAIHost { get }
    func edit(headerFields: HTTPFields) -> HTTPFields
}

public extension LLMSerivce {
    func edit(headerFields: HTTPFields) -> HTTPFields { headerFields }
}
