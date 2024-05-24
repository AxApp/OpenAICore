import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


@main
struct macroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumSingleValueCodableMacro.self,
    ]
}
