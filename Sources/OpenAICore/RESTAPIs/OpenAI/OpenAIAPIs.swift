//
//  File.swift
//  
//
//  Created by linhey on 2024/4/20.
//

import Foundation

public struct OpenAIAPIs: OpenAIAPICollection, OpenAICompatibilityFileAPICollection {
   
    public typealias File = OAIFile.Response
    public typealias Purpose = OAIFile.Purpose
    public typealias Deleted = OAIFile.Deleted
  
    public var file_paths: OpenAICompatibilityFilePaths = .init(.openAI)
    public var client: any LLMClientProtocol
    public var serivce: any LLMSerivce
    
    public init(client: any LLMClientProtocol, serivce: any LLMSerivce) {
        self.client = client
        self.serivce = serivce
    }
    
}
