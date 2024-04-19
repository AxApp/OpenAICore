//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaCopyModel {
    
    public struct Parameters: Codable {
        public var source: String
        public var destination: String
        public init(source: String, destination: String) {
            self.source = source
            self.destination = destination
        }
    }
    
    public typealias Response = Void
    
}
