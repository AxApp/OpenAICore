//
//  File.swift
//  
//
//  Created by linhey on 2024/4/4.
//

import Foundation

public struct MoonshotChatCompletionAPIs {
    
    public let client: OAIClientProtocol
    public let serivce: MoonshotSerivce
    
    public init(client: OAIClientProtocol, serivce: MoonshotSerivce) {
        self.client = client
        self.serivce = serivce
    }
    
}
