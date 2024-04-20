//
//  File.swift
//  
//
//  Created by linhey on 2024/4/18.
//

import Foundation
import OpenAICore
import XCTest


final class OllamaTests: XCTestCase {
    
    class Serivce: LLMSerivce {
        var host: LLMHost = .init("http://localhost:11434")
    }
    
    let apis = OllamaAPIs(client: OAIClient.shared, serivce: Serivce())
    
    func test_embeddings() async throws {
//        let res = try await apis.embeddings(.init(model: "mxbai-embed-large", prompt: "Here is an article about llamas..."))
//        let res = try await apis.show(.init(name: "llama3"))
//        let res = try await apis.list()
//        let res = try await apis.blobs_check(.init(digest: "71a106a910165bc11d43aa128d99e32576a91cbd3e272016abd049f7a09b3235"))
//        let res = try await apis.generate(.init(model: "llama3", prompt: "介绍下自己", stream: false))
        let res = try await apis.chat(.init(model: "llama3", messages: [
            .init(role: .user, content: "介绍下自己")
        ]))

        print(res)
    }

    func test_pull() async throws {
//         _ = try await apis.pull_model(.init(name: "llama2"))
         try await apis.delete(.init(name: "llama2:latest"))
    }
    
    
}

