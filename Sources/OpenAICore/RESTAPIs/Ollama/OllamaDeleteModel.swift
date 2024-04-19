//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaDeleteModel {
    
    public struct Parameters: Codable {
        public var name: String
        public init(name: String) {
            self.name = name
        }
    }
    
    public typealias Response = Void
    
}
