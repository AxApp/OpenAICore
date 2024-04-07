import Foundation

public protocol DocumentTransformer {
    func transformDocuments(_ documents: [LLMDocument]) async throws -> [LLMDocument]
}
