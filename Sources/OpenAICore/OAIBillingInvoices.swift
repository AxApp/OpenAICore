//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation

public struct OAIBillingInvoices: OAIAPI {
    
    public let path: OAIPath = .billing_invoices
    public let query: OAIStaticQuery = .init(["system": "api"])
    
    public init() { }
    
    public typealias Query = OAIStaticQuery
    
    public struct Invoice: Codable {
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
    
    public struct Response: Codable {
        
        public let object: String
        public let data: [Invoice]
    }
    
}
