//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaShowModel {
    
    public struct Parameters: Codable {
        public var name: String
        
        public init(name: String) {
            self.name = name
        }
    }
    
    public struct Response: Codable {
        public var modelfile: String
        public var parameters: String
        public var template: String
        public var details: ModelDetails
    }

    public struct ModelDetails: Codable {
        public var format: String
        public var family: String
        public var families: [String]
        public var parameter_size: String
        public var quantization_level: String
    }

    
}
