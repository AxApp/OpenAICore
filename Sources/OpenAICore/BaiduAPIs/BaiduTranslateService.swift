//
//  File.swift
//  
//
//  Created by linhey on 2024/4/7.
//

import Foundation
import HTTPTypes

public struct BaiduTranslateService {
    
    public var host: OAIHost
    public var appID: String
    public var appKey: String
    
    public init(appID: String, appKey: String, host: OAIHost = .baidu_fanyi) {
        self.appID = appID
        self.appKey = appKey
        self.host = host
    }
   
}


public extension OAIClientProtocol {
    
    func request(of serivce: BaiduTranslateService, path: String) -> HTTPRequest {
        var request = HTTPRequest(method: .get, url: URL(string: serivce.host.rawValue)!)
        var path = path
        if !path.hasPrefix("/") {
            path = "/\(path)"
        }
        request.path = path
        return request
    }
    
}
