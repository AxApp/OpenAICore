//
//  File.swift
//  
//
//  Created by linhey on 2024/5/23.
//

import Foundation

public enum MacroExpansionError: Error, CustomStringConvertible {
    case message(String)
    
    public var description: String {
        switch self {
        case .message(let msg):
            return msg
        }
    }
}
