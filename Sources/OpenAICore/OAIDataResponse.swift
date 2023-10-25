//
//  File.swift
//
//
//  Created by linhey on 2023/9/26.
//

import Foundation

public struct OAIDataResponse<Value: Codable>: Codable {
    
    public enum Object: String, Codable {
        case list
    }
    
    public let data: Value
    public let object: Object
    public let has_more: Bool?
    
    public init(data: Value,
                object: Object,
                has_more: Bool?) {
        self.data = data
        self.object = object
        self.has_more = has_more
    }
    
}
