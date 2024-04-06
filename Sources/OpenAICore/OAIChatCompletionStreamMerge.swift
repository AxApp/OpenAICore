//
//  File.swift
//  
//
//  Created by linhey on 2024/4/6.
//

import Foundation

public actor OAIChatCompletionStreamMerge {
    
    public var chunks = [OAIChatCompletion.CreateChunkResponse]()
    public var isDone = false
    
    public init() { }
    
    public func append(chunk data: Data) throws {
        guard let eventString = String(data: data, encoding: .utf8) else { return }
        for message in SSEParser.parse(from: eventString) {
            switch message.kind {
            case .data:
                if message.value == "[DONE]" {
                    isDone = true
                } else {
                    let completion = try JSONDecoder.shared.decode(OAIChatCompletion.CreateChunkResponse.self, from: data)
                    chunks.append(completion)
                }
            case .id:
                break
            case .event:
                break
            case .comment:
                break
            }
        }
    }
    
    public func merge() -> OAIChatCompletion.CreateResponse {
        guard let first = chunks.first, let last = chunks.last else {
            return .init()
        }
        
        var response = OAIChatCompletion.CreateResponse(id: last.id,
                                                        object: last.object,
                                                        created: first.created,
                                                        model: last.model,
                                                        system_fingerprint: first.system_fingerprint,
                                                        usage: last.usage ?? .init(completion_tokens: chunks.count))
        var raw_store = [Int: OAIChatCompletion.ChunkChoice]()
        chunks.map(\.choices).joined().forEach { choice in
            if var raw = raw_store[choice.index] {
                raw.finish_reason = choice.finish_reason ?? raw.finish_reason
                raw.logprobs.content.append(contentsOf: choice.logprobs.content)
                if let content = choice.delta.content {
                    raw.delta.content = (raw.delta.content ?? "") + content
                }
                if let role = choice.delta.role {
                    raw.delta.role = role
                }
                if let tool_calls = choice.delta.tool_calls {
                    raw.delta.tool_calls = tool_calls
                }
            } else {
                raw_store[choice.index] = choice
            }
        }
        
        response.choices = raw_store
            .map(\.value)
            .sorted(by: { $0.index < $1.index })
            .map { choice in
                OAIChatCompletion.Choice.init(index: choice.index,
                                              message: .init(role: choice.delta.role ?? .assistant,
                                                             content: choice.delta.content,
                                                             tool_calls: choice.delta.tool_calls),
                                              logprobs: choice.logprobs,
                                              finish_reason: choice.finish_reason)
            }
        return response
    }
}
