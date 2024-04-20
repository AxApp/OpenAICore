//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaAPIs: OllamaAPICollection {
    public var client: LLMClientProtocol
    public var serivce: any LLMSerivce
    public init(client: LLMClientProtocol, serivce: any LLMSerivce) {
        self.client = client
        self.serivce = serivce
    }
}
