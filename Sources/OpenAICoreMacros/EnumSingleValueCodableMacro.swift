import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EnumSingleValueCodableMacro: ExtensionMacro {

    public static func expansion(of node: AttributeSyntax,
                                 attachedTo declaration: some DeclGroupSyntax,
                                 providingExtensionsOf type: some TypeSyntaxProtocol,
                                 conformingTo protocols: [TypeSyntax],
                                 in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MacroExpansionError.message("Macro can only be applied to enums")
        }
        guard declaration.inheritanceClause?.inheritedTypes.map(\.type.trimmedDescription).contains("Codable") == true else {
            throw MacroExpansionError.message("Macro can only be applied to enums conforming to Codable")
        }

        let enumName = enumDecl.name.text
        var decodes = [String]()
        var encodes = [String]()

        for enumCase in enumDecl.memberBlock.members.compactMap({ $0.decl.as(EnumCaseDeclSyntax.self) }) {
            for element in enumCase.elements {
                let caseName = element.name.text
                guard let associatedValue = element.parameterClause,
                      associatedValue.parameters.count == 1,
                      let associatedType = associatedValue.parameters.first?.type.description else {
                    throw MacroExpansionError.message("Only enums with a single associated value are supported")
                }
                
                decodes.append("if let value = try? container.decode(\(associatedType).self) { self = .\(caseName)(value); return }")
                encodes.append("case .\(caseName)(let value): try container.encode(value)")
            }
        }

        let extensionDecl = try ExtensionDeclSyntax("""
        extension \(raw: enumName) {
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                \(raw: decodes.joined(separator: "\n"))
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode \(raw: enumName)")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                \(raw: encodes.joined(separator: "\n"))
                }
            }
        }
        """)

        return [extensionDecl]
    }
}
