//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation

public struct OAIBillingInvoices: Codable {
    public let object: String
    public let id: String
    public let number: String
    public let amount_due: Int
    public let amount_paid: Int
    public let tax: Int
    public let total_excluding_tax: Int
    public let total: Int
    public let created: Int
    public let pdf_url: String
    public let hosted_invoice_url: String
    public let collection_method: String
    public let due_date: String?
    public let status: String
}

public struct OAIBillingSubscription: Codable {
    
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

public struct OAIBillingUsage: Codable {
    
    public struct LineItem: Codable {
        public let name: String
        public let cost: Double
    }
    
    public enum LineItemKind: String, Codable {
        case chat  = "Chat models"
        case gpt4  = "GPT-4"
        case image = "Image models"
        case audio = "Audio models"
        case instruct = "Instruct models"
        case fineTuned = "Fine-tuned models"
        case embedding = "Embedding models"
    }
    
    public struct DailyCosts: Codable {
        public let timestamp: Date
        private let line_items: [LineItem]
        
        public var items: [LineItemKind: Double] {
            var list = [LineItemKind: Double]()
            for item in line_items {
                if let kind = LineItemKind(rawValue: item.name) {
                    list[kind] = item.cost
                }
            }
            return list
        }
    }
    
    public let object: String
    public let total_usage: Double
    public let daily_costs: [DailyCosts]
}
