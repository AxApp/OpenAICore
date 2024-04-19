//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//

import Foundation

public enum OllamaResponseFormat: String, Codable {
    case json
}

public enum OllamaMessageRole: String, Codable {
    case system
    case user
    case assistant
}
