//
//  OpenAI.swift
//  Oasis
//
//  Created by Sergii Kryvoblotskyi on 9/18/22.
//

import Foundation

final public class OpenAI {
    
    public let serivce: OAISerivce
    
    public init(token: String, organization: String? = nil) {
        self.serivce = .init(token: token,
                             organization: organization ?? "",
                             host: OAIHost.openAI)
    }
    
    public init(serivce: OAISerivce) {
        self.serivce = serivce
    }
    
}

public extension OpenAI {
    
    func uri(_ path: OAIPath) -> String {
        var uri = serivce.host.rawValue
        if uri.hasSuffix("/") {
            uri.append(path.rawValue)
        } else {
            uri.append("/")
            uri.append(path.rawValue)
        }
        return uri
    }
    
    func headers() -> [String: String] {
        var headers = [String: String]()
        headers["Content-Type"]  = "application/json"
        if !serivce.token.isEmpty {
            headers["Authorization"] = "Bearer \(serivce.token)"
        }
        if !serivce.organization.isEmpty {
            headers["OpenAI-Organization"]  = serivce.organization
        }
        return headers
    }
    
}



