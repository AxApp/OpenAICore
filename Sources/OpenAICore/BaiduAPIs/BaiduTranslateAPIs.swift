//
//  File.swift
//  
//
//  Created by linhey on 2024/4/7.
//

import Foundation

public struct BaiduTranslateAPIs {
    
    public let client: OAIClientProtocol
    public let serivce: BaiduTranslateService
    
    public init(client: OAIClientProtocol, serivce: BaiduTranslateService) {
        self.client = client
        self.serivce = serivce
    }
    
}

public extension BaiduTranslateAPIs {
    
    func trans_vip_translate(_ parameter: BaiduTranslate.TranslateParameter) async throws -> BaiduTranslate.TranslateResponse {
        var request = client.request(of: serivce, path: "api/trans/vip/translate")
        request = client.add(queries: parameter.sign(serivce), to: request)
        let response = try await client.data(for: request)
        if let error: BaiduTranslate.ErrorResponse = try? client.decode(response.data) {
            throw error
        }
        return try client.decode(response.data)
    }
    
}
