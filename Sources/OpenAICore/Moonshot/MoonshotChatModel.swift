//
//  File.swift
//  
//
//  Created by linhey on 2024/4/4.
//

import Foundation

public struct MoonshotChatModel: Equatable, Codable, Hashable {
    
    public let name: String
    public let token: Int
    
    public init(token: Int, name: String) {
        self.name = name
        self.token = token
    }
    
}

public extension MoonshotChatModel {
    
    static let v1s: [MoonshotChatModel] = [
        .moonshot_v1_8k,
        .moonshot_v1_32k,
        .moonshot_v1_128k
    ]
    
    static let moonshot_v1_8k   = MoonshotChatModel(token: 8000, name: "moonshot-v1-8k")
    static let moonshot_v1_32k  = MoonshotChatModel(token: 32000, name: "moonshot-v1-32k")
    static let moonshot_v1_128k = MoonshotChatModel(token: 128000, name: "moonshot-v1-128k")

}
