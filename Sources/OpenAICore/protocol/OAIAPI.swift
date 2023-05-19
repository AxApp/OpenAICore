//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation

public protocol OAIAPI {
    associatedtype Query: OAIAPIQuery
    associatedtype Response: Codable
    var decoder: JSONDecoder { get }
    var path: OAIPath { get }
    var query: Query { get }
}

public extension OAIAPI {
    
    var decoder: JSONDecoder {
        let item = JSONDecoder()
        item.dateDecodingStrategy = .secondsSince1970
        return item
    }
    
}
