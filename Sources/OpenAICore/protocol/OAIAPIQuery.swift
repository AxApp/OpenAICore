//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation
import STJSON


public protocol OAIAPIQuery {
    
    func serialize() throws -> JSON

}

public extension Array where Element: OAIAPIQuery {
    
    func serialize() throws -> JSON {
       JSON(try self.map({ try $0.serialize() }))
    }
    
}

public extension OAIAPIQuery where Self: Codable {

    func serialize() throws -> JSON {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return try JSON(data: data)
    }
    
}
