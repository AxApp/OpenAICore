//
//  File.swift
//  
//
//  Created by linhey on 2023/3/23.
//

import Foundation

///MARK: - Images
public struct OAIImages: OAIAPI {
    
    public let path: OAIPath = .images
    public var query: Query
    
    public init(query: Query) {
        self.query = query
    }
    
    public struct Query: OAIAPIQuery, Codable {
        /// A text description of the desired image(s). The maximum length is 1000 characters.
        public let prompt: String
        /// The number of images to generate. Must be between 1 and 10.
        public let n: Int?
        /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
        public let size: String?
        
        public init(prompt: String, n: Int?, size: String?) {
            self.prompt = prompt
            self.n = n
            self.size = size
        }
    }
    
    public struct Response: Codable {
        public struct URLResult: Codable {
            public let url: String
        }
        public let created: TimeInterval
        public let data: [URLResult]
    }
    
}
