//
//  File.swift
//  
//
//  Created by linhey on 2024/5/22.
//

import Foundation

public struct OpenAICompatibilityAPIs: OpenAICompatibilityChatAPICollection, OpenAICompatibilityFileAPICollection { 
    
    public typealias File    = OpenAICompatibilityFile.Response
    public typealias Purpose = OpenAICompatibilityFile.Purpose
    public typealias Deleted = OAIFile.Deleted
    
    public static func moonshot(_ client: any LLMClientProtocol, token: String) -> OpenAICompatibilityAPIs {
        OpenAICompatibilityAPIs(client: client, serivce: OAISerivce(token: token, host: .moonshot), paths: .moonshot)
    }
    
    public static func qwen(_ client: any LLMClientProtocol, token: String) -> OpenAICompatibilityAPIs {
        OpenAICompatibilityAPIs(client: client, serivce: OAISerivce(token: token, host: .qwen), paths: .qwen)
    }
    
    public var client: any LLMClientProtocol
    public var serivce: any LLMSerivce
    public var chat_paths: OpenAICompatibilityChatPaths
    public var file_paths: OpenAICompatibilityFilePaths

    public init(client: any LLMClientProtocol,
                serivce: any LLMSerivce,
                paths: LLMAPIPath) {
        self.client = client
        self.serivce = serivce
        self.chat_paths = .init(paths)
        self.file_paths = .init(paths)
    }
    
}
