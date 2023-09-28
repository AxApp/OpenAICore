//
//  File.swift
//  
//
//  Created by linhey on 2023/9/26.
//

import Foundation

struct OAIDataResponse<T: Codable>: Codable {
    
    enum Object: String, Codable {
        case list
    }
    
    let data: T
    let object: Object
    let has_more: Bool?
    
}
