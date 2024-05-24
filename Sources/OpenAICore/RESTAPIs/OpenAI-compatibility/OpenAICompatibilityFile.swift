//
//  File.swift
//  
//
//  Created by linhey on 2024/5/23.
//

import Foundation

public struct OpenAICompatibilityFile {
    
    public struct Deleted: Codable, Identifiable {
        public let id: String
        public let object: Object
        public let deleted: Bool
    }
    
    public enum Purpose: String, Codable {
        case file_extract = "file-extract"
    }
    
    public enum Object: String, Codable {
        case file
    }
    
    public enum Status: String, Codable {
        case uploaded
        case processed
        case pending
        case error
        case deleting
        case deleted
        case ok
    }
    
    public typealias Response = File<Status>
    public struct File<Status: Codable>: Codable, Identifiable {
        /// 文件的唯一标识符，可在API端点中引用。
        public let id: String
        /// 对象类型，始终为 "file"。
        public let object: Object
        /// 文件大小（以字节为单位）。
        public let bytes: Int
        /// 文件创建的Unix时间戳（以秒为单位）。
        public let created_at: Int
        /// 文件名称。
        public let filename: String
        /// 文件的预期用途。目前仅支持 "fine-tune"。
        public let purpose: Purpose
        /// 文件的当前状态，可以是 uploaded, processed, pending, error, deleting, 或 deleted。
        public let status: Status
        /// 关于文件状态的额外细节。如果文件处于错误状态，此字段将包含描述错误的消息。可为null。
        public let status_details: String?
    }
    
}
