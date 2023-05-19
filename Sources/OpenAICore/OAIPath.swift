//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation

public struct OAIPath: RawRepresentable, Codable, Equatable {
            
    public static let billing_subscription = OAIPath(rawValue: "v1/dashboard/billing/subscription")
    public static let billing_invoices     = OAIPath(rawValue: "v1/dashboard/billing/invoices")
    public static let billing_usage        = OAIPath(rawValue: "v1/dashboard/billing/usage")
    public static let models               = OAIPath(rawValue: "v1/models")
    public static let completions          = OAIPath(rawValue: "v1/completions")
    public static let images               = OAIPath(rawValue: "v1/images/generations")
    public static let embeddings           = OAIPath(rawValue: "v1/embeddings")
    public static let chats                = OAIPath(rawValue: "v1/chat/completions")
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
