//
//  File.swift
//  
//
//  Created by linhey on 2024/4/7.
//

import OpenAICore
import XCTest

final class BaiduAPIsTests: XCTestCase {
    
    let service = BaiduTranslateService(appID: "xxxx", appKey: "xxxx")
    
    func test_trans_vip_translate() async throws {
       let res = try await BaiduTranslateAPIs(client: OAIClient.shared, serivce: service)
            .trans_vip_translate(.init(q: "HF is a complex clinical syndrome caused by abnormal changes in cardiac structure and/or function via various mechanisms, which results in ventricular systolic and/or diastolic dysfunction. It is a severe manifestation or terminal stage of various heart diseases. In the early stage of HF, the stress response signiﬁ cantly increases the levels of epinephrine, glucagon, and glucocorticoids to above the physiological ranges. In the later stage, due to low cardiac output, the adrenal cortex is ischemic and hypoxic due to hypoperfusion, so its function of synthesizing corticosteroids is impaired, resulting in decreased blood cortisol.", from: .auto, to: .zh))
        print(res)
    }
    
}
