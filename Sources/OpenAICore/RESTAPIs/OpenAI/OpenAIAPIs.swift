//
//  File.swift
//  
//
//  Created by linhey on 2024/4/20.
//

import Foundation

public struct OpenAIAPIs: OpenAIAPICollection {
    
    public var client: any LLMClientProtocol
    public var serivce: any LLMSerivce
    
    public init(client: any LLMClientProtocol, serivce: any LLMSerivce) {
        self.client = client
        self.serivce = serivce
    }
    
}
