//
//  File.swift
//  
//
//  Created by linhey on 2024/4/6.
//

import Foundation

public actor OAIChatCompletionStreamMerge {
    
    public enum Kind {
        case chunk(Data)
        case finish
        case other(Data)
    }
    
    public var chunks = [OAIChatCompletion.CreateChunkResponse]()
    
    public init() { }

    public func parse(chunk data: Data) throws -> [Kind] {
        guard let eventString = String(data: data, encoding: .utf8) else { return [.other(data)] }
        var kinds = [Kind]()
        for message in SSEParser.parse(from: eventString) {
            switch message.kind {
            case .data:
                if message.value == "[DONE]" {
                    kinds.append(.finish)
                } else {
                    kinds.append(.chunk(message.value.data(using: .utf8) ?? .init()))
                }
            case .id:
                break
            case .event:
                break
            case .comment:
                break
            }
        }
        return kinds
    }
    
    public func append(_ item: OAIChatCompletion.CreateChunkResponse) {
        self.chunks.append(item)
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
                raw_store[choice.index] = raw
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
