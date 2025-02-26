import Foundation

public protocol LLMDocumentLoader {
    func load() async throws -> [LLMDocument]
}

public extension LLMDocumentLoader {
    
    func load(splitter: TextSplitter?) async throws -> [LLMDocument] {
        let docs = try await load()
        return try await splitter?.splitDocuments(docs) ?? docs
    }
    
}

