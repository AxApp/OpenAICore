//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaModelList {
    
    typealias Parameters = Void
    
    public struct Response: Codable {
        public var models: [Model]
        
        public struct Model: Codable {
            public var name: String
            public var modified_at: String
            public var size: Int64
            public var digest: String
            public var details: ModelDetails
        }
        
        public struct ModelDetails: Codable {
            public var format: String
            public var family: String
            public var families: [String]?
            public var parameter_size: String
            public var quantization_level: String
        }
    }
    
}
