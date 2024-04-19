//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaCreateBlob {
    
    public struct Parameters: Codable {
        public var digest: String
        public init(digest: String) {
            self.digest = digest
        }
    }
    
    public typealias Response = Void
    
    
}
