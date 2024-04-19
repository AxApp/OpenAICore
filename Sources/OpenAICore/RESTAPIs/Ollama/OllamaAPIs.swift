//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaAPIs: OllamaAPICollection {
    public var client: OAIClientProtocol
    public var serivce: LLMSerivce
    public init(client: OAIClientProtocol, serivce: LLMSerivce) {
        self.client = client
        self.serivce = serivce
    }
}
