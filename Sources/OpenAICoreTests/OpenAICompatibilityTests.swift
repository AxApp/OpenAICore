//
//  OpenAICompatibilityTests.swift
//  
//
//  Created by linhey on 2024/5/22.
//

import OpenAICore
import XCTest

public class OpenAICompatibilityTests: XCTestCase {
        
    let moonshotAPIs = OpenAICompatibilityAPIs.moonshot(OAIClient.shared, token: "sk-")

    
    func test_qwen() async throws {
        let request = OpenAICompatibilityAPIs.bailian(OAIClient.shared, token: "sk-")

        var parameters = OpenAICompatibilityChatCompletion.Parameters()
        parameters.model = .qwen_turbo
        parameters.messages = [
            .text(.init(role: .system, content: "You are a helpful assistant.")),
            .text(.init(role: .user, content: "你是谁？"))
        ]
        let result = try await request.chat_completions(parameters)
        print(result)
    }
    
    func test_kimi_partial() async throws {
        var parameters = OpenAICompatibilityChatCompletion.Parameters()
        parameters.model = .moonshot_v1_8k
        parameters.messages = [
            .text(.init(role: .system, content: "下面你扮演凯尔希，请用凯尔希的语气和我对话。凯尔希是手机游戏《明日方舟》中的六星医疗职业医师分支干员。前卡兹戴尔勋爵，前巴别塔成员，罗德岛高层管理人员之一，罗德岛医疗项目领头人。在冶金工业、社会学、源石技艺、考古学、历史系谱学、经济学、植物学、地质学等领域皆拥有渊博学识。于罗德岛部分行动中作为医务人员提供医学理论协助与应急医疗器械，同时也作为罗德岛战略指挥系统的重要组成人员活跃在各项目中。")),
            .text(.init(role: .user, content: "你怎么看待特蕾西娅和阿米娅？")),
            .moonshot(.partial(.init(role: .assistant, name: "凯尔希")))
        ]
        let result = try await moonshotAPIs.chat_completions(parameters)
        print(result)
    }
    
    
    func test_kimi_partial_json_mode() async throws {
        var parameters = OpenAICompatibilityChatCompletion.Parameters()
        parameters.model = .moonshot_v1_8k
        parameters.messages = [
            .text(.init(role: .system, content: "请从产品描述中提取名称、尺寸、价格和颜色，并在一个 JSON 对象中输出。")),
            .text(.init(role: .user, content: "大米 SmartHome Mini 是一款小巧的智能家居助手，有黑色和银色两种颜色，售价为 998 元，尺寸为 256 x 128 x 128mm。可让您通过语音或应用程序控制灯光、恒温器和其他联网设备，无论您将它放在家中的任何位置。")),
            .moonshot(.partial(.init(role: .assistant, content: "{")))
        ]
        let result = try await moonshotAPIs.chat_completions(parameters)
        print(result)
    }
    
    func test_kimi_file_list() async throws {
        let result = try await moonshotAPIs.file_list()
        print(result)
    }
    
    func test_kimi_file_upload() async throws {
        let result = try await moonshotAPIs.file_upload(URL.init(filePath: "/Users/linhey/Desktop/丁香园-服务器项目/AxAIGC-Python/tests/test.pdf"),
                                                        purpose: .file_extract)
        print(result)
    }
    
    
    func test_kimi_file() async throws {
        if let file = try await moonshotAPIs.file_list().first {
            let file_retrieve = try await moonshotAPIs.file_retrieve(id: file.id)
            let file_content = try await moonshotAPIs.file_content(id: file.id)
            let result = try await moonshotAPIs.file_delete(id: file.id)
            print(result)
        }
    }
    
}
