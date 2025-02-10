//
//  Test.swift
//  OpenAICore
//
//  Created by linhey on 2/8/25.
//

import Testing
import OpenAICore
import Alamofire

struct Test {
    
    enum Keys {
        static let tencent  = "sk-0yw81eF8MTAxxxuc3Zzw4cHYiV9RwH8q"
        static let ark      = "sk-xxxx-b9b5-47b7-b28f-4936bf99f731"
        static let deepseek = "sk-xxxxxbea85c501xxxxx28f3bf3bd84fd"
        static let bailian  = "sk-xxxxx2e19540adb12ae847dxxxxxxxxx"
    }
    
    func parameters() -> OpenAICompatibilityChatCompletion.Parameters {
        var parameters = OpenAICompatibilityChatCompletion.Parameters()
        parameters.model = .init(token: .x64k, organization: .bytedance, name: "ep-20250208161948-25h46")
        parameters.stream = false
        parameters.response_format = .json_object()
        parameters.messages = [
            .text(role: .system, content: """
                  你是植物专家. 你回答一些问题. 请告诉我你想要了解的植物的名称和描述.
                  输出 JSON 示例:
                  [{
                      "name": "十字花科植物",
                      "description": "十字花科植物是一类植物，...",
                  }]
                  """),
            .text(role: .user, content: "常见的十字花科植物有哪些？")
        ]
        return parameters
    }
    
    
    /// 27.13s | 支持 Json
    @Test func tencent_deepseek_v3() async throws {
        let api = OpenAICompatibilityAPIs.tencent(OAIClient.shared, token: Keys.tencent)
        var parameters = self.parameters()
        parameters.model = parameters.model?.name("deepseek-v3")
        let result = try await api.chat_completions(parameters)
        print(result)
    }

    /// 3.97s | 支持 Json
    @Test func bailian_qwen_plus_latest() async throws {
        let api = OpenAICompatibilityAPIs.bailian(OAIClient.shared, token: Keys.bailian)
        var parameters = self.parameters()
        parameters.model = parameters.model?.name("qwen-plus-latest")
        let result = try await api.chat_completions(parameters)
        print(result)
    }

    /// 3.80s | 支持 Json
    @Test func bailian_qwen_max_latest() async throws {
        let api = OpenAICompatibilityAPIs.bailian(OAIClient.shared, token: Keys.bailian)
        var parameters = self.parameters()
        parameters.model = parameters.model?.name("qwen-max-latest")
        let result = try await api.chat_completions(parameters)
        print(result)
    }
    
    /// 15.10s | 支持 Json
    @Test func bailian_deepseek_v3() async throws {
        let api = OpenAICompatibilityAPIs.bailian(OAIClient.shared, token: Keys.bailian)
        var parameters = self.parameters()
        parameters.model = parameters.model?.name("deepseek-v3")
        let result = try await api.chat_completions(parameters)
        print(result)
    }
    
    /// 1.11 min | 支持 Json
    @Test func ark_Doubao_1_5_pro_32k() async throws {
        let api = OpenAICompatibilityAPIs.ark(OAIClient.shared, token: Keys.ark)
        var parameters = self.parameters()
        parameters.model = parameters.model?.name("ep-20250208171846-6mhqq")
        let result = try await api.chat_completions(parameters)
        print(result)
    }
    
    /// 1.49 min | 支持 Json
    @Test func ark_deepseek_v3() async throws {
        let api = OpenAICompatibilityAPIs.ark(OAIClient.shared, token: Keys.ark)
        var parameters = self.parameters()
        parameters.model = parameters.model?.name("ep-20250208151731-mhxc7")
        let result = try await api.chat_completions(parameters)
        print(result)
    }
    
    /// 1.06 min | 不支持 Json 输出
    @Test func ark_deepseek_r1() async throws {
        let api = OpenAICompatibilityAPIs.ark(OAIClient.shared, token: Keys.ark)
        var parameters = self.parameters()
        parameters.model = parameters.model?.name("ep-20250208161948-25h46")
        let result = try await api.chat_completions(parameters)
        print(result)
    }
    
    /// 18.5s | 支持 Json
    @Test func deepseek_v3() async throws {
        let api = OpenAICompatibilityAPIs.deepseek(OAIClient.shared, token: Keys.deepseek)
        var parameters = self.parameters()
        parameters.model = parameters.model?.name("deepseek-chat")
        let result = try await api.chat_completions(parameters)
        print(result)
    }
    
    /// 报错 | 不支持 Json 输出
    @Test func deepseek_r1() async throws {
        let api = OpenAICompatibilityAPIs.deepseek(OAIClient.shared, token: Keys.deepseek)
        var parameters = self.parameters()
        parameters.model = parameters.model?.name("deepseek-reasoner")
        let result = try await api.chat_completions(parameters)
        print(result)
    }

}
