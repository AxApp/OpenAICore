//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation


public protocol OAIAPIQuery {
    
    func serialize() throws -> [String: Any]
    func serializeData() throws -> Data

}

public extension OAIAPIQuery {
    
    func serializeData() throws -> Data {
       try JSONSerialization.data(withJSONObject: serialize())
    }
    
}

public extension OAIAPIQuery where Self: Codable {
    
    func serialize() throws -> [String: Any] {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            return (try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
        } catch {
            assertionFailure()
            return [:]
        }
    }
    
}
