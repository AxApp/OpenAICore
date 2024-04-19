//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaCreateModel {
    
    public struct Parameters: Codable {
        public var name: String
        public var modelfile: String?
        public var stream: Bool?
        public var path: String?
        public init(name: String, modelfile: String? = nil, stream: Bool = false, path: String? = nil) {
            self.name = name
            self.modelfile = modelfile
            self.stream = stream
            self.path = path
        }
    }

    public struct Response: Codable {
        public var status: String
    }
    
}
