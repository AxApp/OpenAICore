import Foundation
import AnyCodable

public struct Document: Codable {
    public typealias Metadata = [String: AnyCodable]
    public var pageContent: String
    public var metadata: Metadata
    public init(pageContent: String, metadata: Metadata) {
        self.pageContent = pageContent
        self.metadata = metadata
    }
}

public protocol DocumentLoader {
    func load() async throws -> [Document]
}

public extension DocumentLoader {
    
    func load(splitter: TextSplitter?) async throws -> [Document] {
        let docs = try await load()
        return try await splitter?.splitDocuments(docs) ?? docs
    }
    
}

