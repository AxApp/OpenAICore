//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public struct OllamaPullModel {
    
    // Request Structure
    public struct Parameters: Codable {
        public var name: String
        public var insecure: Bool?
        public var stream: Bool
        
        public init(name: String, insecure: Bool? = nil, stream: Bool = false) {
            self.name = name
            self.insecure = insecure
            self.stream = stream
        }
    }

    // Possible Responses
    public struct DownloadResponse: Codable {
        public let status: String
        public let digest: String?
        public let total: Int?
        public let completed: Int?
    }

    public struct SimpleStatusResponse: Codable {
        public let status: String
    }

    // To handle multiple response types based on streaming
    public enum Response: Codable {
        case download([DownloadResponse])
        case simple(SimpleStatusResponse)

        public init(from decoder: Decoder) throws {
            if let array = try? decoder.singleValueContainer().decode([DownloadResponse].self) {
                self = .download(array)
                return
            }
            if let single = try? decoder.singleValueContainer().decode(SimpleStatusResponse.self) {
                self = .simple(single)
                return
            }
            throw DecodingError.typeMismatch(Response.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to decode Array<DownloadResponse> or SimpleStatusResponse"))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .download(let array):
                var container = encoder.singleValueContainer()
                try container.encode(array)
            case .simple(let single):
                var container = encoder.singleValueContainer()
                try container.encode(single)
            }
        }
    }
    
}
