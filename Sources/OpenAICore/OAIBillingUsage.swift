//
//  File.swift
//  
//
//  Created by linhey on 2023/5/19.
//

import Foundation

public struct OAIBillingUsage: OAIAPI {
    
    public var path: OAIPath { .billing_usage }
    public var query: Query
    
    public init(_ query: Query) {
        self.query = query
    }
    
    public struct Query: OAIAPIQuery {
        
        public let from: Date
        public let to: Date
        private let formatter = DateFormatter()
        
        public init(from: Date? = nil, to: Date = .init()) {
            self.from = from ?? to.addingTimeInterval(-100 * 24 * 60 * 60)
            self.to = to
            formatter.dateFormat = "yyyy-MM-dd"
        }
        
        public func serialize() -> [String: Any] {
            return [
                "start_date": formatter.string(from: from),
                "end_date": formatter.string(from: to)
            ]
        }
    }
    
    public struct Response: Codable {
        public let object: String
        public let total_usage: Double
        public let daily_costs: [DailyCosts]
    }
    
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
    
}

