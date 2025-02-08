//
//  File.swift
//  
//
//  Created by linhey on 2024/5/22.
//

import Foundation

// https://open.bigmodel.cn/dev/api#http_auth
// https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation
// https://dashscope.aliyuncs.com/compatible-mode/v1
// https://platform.openai.com/docs/api-reference/chat/create
// https://platform.moonshot.cn/docs/api/chat#%E5%85%AC%E5%BC%80%E7%9A%84%E6%9C%8D%E5%8A%A1%E5%9C%B0%E5%9D%80
// https://console.volcengine.com/ark/region:ark+cn-beijing/endpoint/detail?Id=ep-20250208151731-mhxc7&Tab=api
// https://api-docs.deepseek.com/zh-cn/guides/reasoning_model
public struct LLMAPIPath: Sendable {
    let prefix: String
    public static let moonshot = LLMAPIPath(prefix: "v1")
    public static let openAI   = LLMAPIPath(prefix: "v1")
    public static let deepseek = LLMAPIPath(prefix: "v1")
    public static let bailian  = LLMAPIPath(prefix: "compatible-mode/v1")
    public static let zhipuai  = LLMAPIPath(prefix: "api/paas/v4")
    public static let ark      = LLMAPIPath(prefix: "api/v3")
}

