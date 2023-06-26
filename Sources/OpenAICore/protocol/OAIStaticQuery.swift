//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation
import STJSON

public struct OAIStaticQuery: OAIAPIQuery {
    
    public static let empty = OAIStaticQuery()
    let dict: [String: Any]
    
    public init(_ dict: [String : Any] = [:]) {
        self.dict = dict
    }
    
    public func serialize() throws -> JSON {
        .init(self.dict)
    }
    
}
