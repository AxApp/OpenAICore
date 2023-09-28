//
//  File.swift
//
//
//  Created by linhey on 2023/3/23.
//

import Foundation

///MARK: - Images
public struct OAIImage: Codable {
    
    let url: URL?
    let b64_json: String?
    
}

public struct OAIImagesAPIs {
    
    public let client: OAIClientProtocol
    public let serivce: OAISerivce
    
    public init(client: OAIClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }
    
    public enum CreateSize: String, Codable {
        case x256  = "256x256"
        case x512  = "512x512"
        case x1024 = "1024x1024"
    }
    
    public enum CreateResponseFormat: String, Codable {
        case url
        case b64_json
    }
    
    public struct GenerationsParameter: Codable {
        /// A text description of the desired image(s). Maximum length is 1000 characters.
        public var prompt: String
        /// The number of images to generate. Must be between 1 and 10. Defaults to 1.
        public var n: Int = 1
        /// The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024". Defaults to "1024x1024".
        public var size: CreateSize = .x1024
        /// The format in which the generated images are returned. Must be "url" or "b64_json". Defaults to "url".
        public var responseFormat: CreateResponseFormat = .url
        /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        public var user: String?
        
        public init(prompt: String,
                    n: Int = 1,
                    size: CreateSize = .x1024,
                    responseFormat: CreateResponseFormat = .url,
                    user: String? = nil) {
            self.prompt = prompt
            self.n = n
            self.size = size
            self.responseFormat = responseFormat
            self.user = user
        }
    }
    
    public func generations(_ parameter: GenerationsParameter) async throws -> [OAIImage] {
        var request = client.request(of: serivce, path: "v1/images/generations")
        request.method = .post
        let request_body = try client.encode(parameter)
        let data = try await client.upload(for: request, from: request_body)
        return try client.decode(data)
    }
    
    public struct EditsParameter: Codable {
        /// The image to edit. Must be a valid PNG file, less than 4MB, and square. If mask is not provided, image must have transparency, which will be used as the mask.
        public var image: String
        /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where should be edited. Must be a valid PNG file, less than 4MB, and have the same dimensions as
        public var mask: String?
        /// A text description of the desired image(s). Maximum length is 1000 characters.
        public var prompt: String
        /// The number of images to generate. Must be between 1 and 10. Defaults to 1.
        public var n: Int = 1
        /// The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024". Defaults to "1024x1024".
        public var size: CreateSize = .x1024
        /// The format in which the generated images are returned. Must be "url" or "b64_json". Defaults to "url".
        public var responseFormat: CreateResponseFormat = .url
        /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        public var user: String?
        
        public init(image: String,
                    mask: String? = nil,
                    prompt: String,
                    n: Int = 1,
                    size: CreateSize = .x1024,
                    responseFormat: CreateResponseFormat = .url,
                    user: String? = nil) {
            self.image = image
            self.mask = mask
            self.prompt = prompt
            self.n = n
            self.size = size
            self.responseFormat = responseFormat
            self.user = user
        }
    }
    
    public func edits(_ parameter: EditsParameter) async throws -> [OAIImage] {
        var request = client.request(of: serivce, path: "v1/images/edits")
        request.method = .post
        let request_body = try client.encode(parameter)
        let data = try await client.upload(for: request, from: request_body)
        return try client.decode(data)
    }
    
    public struct VariationsParameter: Codable {
        /// The image to edit. Must be a valid PNG file, less than 4MB, and square. If mask is not provided, image must have transparency, which will be used as the mask.
        public var image: String
        /// A text description of the desired image(s). Maximum length is 1000 characters.
        public var prompt: String
        /// The number of images to generate. Must be between 1 and 10. Defaults to 1.
        public var n: Int = 1
        /// The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024". Defaults to "1024x1024".
        public var size: CreateSize = .x1024
        /// The format in which the generated images are returned. Must be "url" or "b64_json". Defaults to "url".
        public var responseFormat: CreateResponseFormat = .url
        /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        public var user: String?
        
        public init(image: String,
                    prompt: String,
                    n: Int = 1,
                    size: CreateSize = .x1024,
                    responseFormat: CreateResponseFormat = .url,
                    user: String? = nil) {
            self.image = image
            self.prompt = prompt
            self.n = n
            self.size = size
            self.responseFormat = responseFormat
            self.user = user
        }
    }
    
    public func variations(_ parameter: VariationsParameter) async throws -> [OAIImage] {
        var request = client.request(of: serivce, path: "v1/images/variations")
        request.method = .post
        let request_body = try client.encode(parameter)
        let data = try await client.upload(for: request, from: request_body)
        return try client.decode(data)
    }
    
}
