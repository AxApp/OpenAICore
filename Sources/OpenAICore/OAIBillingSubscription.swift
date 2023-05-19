//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation

public struct OAIBillingSubscription: OAIAPI {
    
    public let path: OAIPath = .billing_subscription
    public let query: OAIStaticQuery = .empty
    
    public init() { }
    
    public typealias Query = OAIStaticQuery
    
    public struct Plan: Codable {
        public let title: String
        public let id: String
    }
    
    public struct BillingAddress: Codable {
        public let city: String
        public let line1: String
        public let state: String
        public let country: String
        public let postal_code: String
    }
    
    public struct Response: Codable {
        
        public let object: String
        public let has_payment_method: Bool
        public let canceled: Bool
        public let canceled_at: Date?
        public let access_until: Int
        public let soft_limit: Int
        public let hard_limit: Int
        public let system_hard_limit: Int
        public let soft_limit_usd: Double
        public let hard_limit_usd: Double
        public let system_hard_limit_usd: Double
        public let plan: Plan?
        public let account_name: String?
        public let po_number: String?
        public let billing_email: String?
        public let billing_address: BillingAddress
        
        // public let delinquent: null
        // "tax_ids": null,
        // "business_address": null
    }
    
}
