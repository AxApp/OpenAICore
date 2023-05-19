//
//  File.swift
//  
//
//  Created by linhey on 2023/3/23.
//

import Foundation

public struct OAIModels: OAIAPI {
    public typealias Query = OAIStaticQuery
    
    public let path: OAIPath = .models
    public var query: OAIStaticQuery = .empty
    public init() {}
    
    public struct Response: Codable {
        
        public struct Model: Codable {
            public let id: String
            public let object: String
            public let created: TimeInterval
            public let ownedBy: String?
            public let permission: [Permission]
        }
        
        public struct Permission: Codable {
            public let id: String
            public let object: String
            public let created: Int
            public let allow_create_engine: Bool
            public let allow_sampling: Bool
            public let allow_logprobs: Bool
            public let allow_search_indices: Bool
            public let allow_view: Bool
            public let allow_fine_tuning: Bool
            public let organization: String
            public let group: String?
            public let is_blocking: Bool
        }
        
        public let data: [Model]
        public let object: String
        public let root: String?
    }
    
}
