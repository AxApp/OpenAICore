//
//  File.swift
//  
//
//  Created by linhey on 2024/5/22.
//

import Foundation

// https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation
// https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation
// https://dashscope.aliyuncs.com/compatible-mode/v1
/// https://platform.openai.com/docs/api-reference/chat/create
/// https://platform.moonshot.cn/docs/api/chat#%E5%85%AC%E5%BC%80%E7%9A%84%E6%9C%8D%E5%8A%A1%E5%9C%B0%E5%9D%80
public struct LLMAPIPath {
    let prefix: String
    public static let qwen     = LLMAPIPath(prefix: "compatible-mode/v1")
    public static let moonshot = LLMAPIPath(prefix: "v1")
    public static let openAI   = LLMAPIPath(prefix: "v1")
}

