import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import OpenAICoreMacros

let testMacros: [String: Macro.Type] = [
    "EnumSingleValueCodable": EnumSingleValueCodableMacro.self
]


final class EnumMacroTests: XCTestCase {
    
    func testEnumMacro() throws {
        // 正确传递宏类型
        assertMacroExpansion(
            """
            @EnumSingleValueCodable
            public enum MoonshotMessage: Codable {
                case text(String)
                case partial(MoonshotPartialMessage)
            }
            """,
            expandedSource: """
            public enum MoonshotMessage: Codable {
                case text(String)
                case partial(MoonshotPartialMessage)
            }
            
            extension MoonshotMessage {
                public init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let value = try? container.decode(String.self) {
                        self = .text(value);
                        return
                    }
                    if let value = try? container.decode(MoonshotPartialMessage.self) {
                        self = .partial(value);
                        return
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode MoonshotMessage")
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .text(let value):
                        try container.encode(value)
                    case .partial(let value):
                        try container.encode(value)
                    }
                }
            }
            """,
            macros: testMacros // 确保传递的是宏类型
        )
    }
    
}
