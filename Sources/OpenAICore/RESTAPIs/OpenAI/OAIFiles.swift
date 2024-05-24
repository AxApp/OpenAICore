//
//  File.swift
//  
//
//  Created by linhey on 2023/9/22.
//

import Foundation

public struct OAIFile {
    
    public enum Purpose: String,Codable {
        case fine_tune = "fine-tune"
        case batch
        case assistants
        case vision
    }
    
    public enum Status: String, Codable {
        case uploaded
        case processed
        case pending
        case error
        case deleting
        case deleted
    }
    
    public typealias Deleted  = OpenAICompatibilityFile.Deleted
    public typealias Response = OpenAICompatibilityFile.File<Status>
    
}
