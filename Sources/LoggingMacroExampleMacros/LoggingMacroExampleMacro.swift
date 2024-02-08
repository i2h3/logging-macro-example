import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum MacroError: Error {
    ///
    /// The macro is added to a type which is not supported.
    ///
    case unsupportedType
}

@main
struct LoggingMacroExamplePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LoggingMacro.self,
    ]
}

public struct LoggingMacro: MemberMacro {
    ///
    /// Get the name of the type which is logging.
    ///
    static func getName(of declaration: some DeclGroupSyntax) throws -> String {
        let identifier: TokenSyntax

        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            identifier = classDecl.name
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            identifier = structDecl.name
        } else if let actorDecl = declaration.as(ActorDeclSyntax.self) {
            identifier = actorDecl.name
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            identifier = enumDecl.name
        } else {
            throw MacroError.unsupportedType
        }

        return identifier.text
    }

    ///
    /// Detect enums.
    ///
    static func isEnum(_ declaration: some DeclGroupSyntax) -> Bool {
        if declaration.as(EnumDeclSyntax.self) != nil {
            return true
        }

        return false
    }

    public static func expansion(of _: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in _: some MacroExpansionContext) throws -> [DeclSyntax] {
        let name = try getName(of: declaration)

        var modifiers = DeclModifierListSyntax()

        if isEnum(declaration) {
            modifiers.append(DeclModifierSyntax(name: "static"))
        }

        let documentationComment = Trivia(pieces: [
            .docLineComment("/// Specific `Logger` for this instance of ``\(name)``."),
            .newlines(1),
        ])

        let pattern = IdentifierPatternSyntax(identifier: .identifier("logger"))

        let typeAnnotation = TypeAnnotationSyntax(colon: .colonToken(), type: IdentifierTypeSyntax(name: .identifier("Logger")))

        let initializer = InitializerClauseSyntax(
            value: FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(baseName: .identifier("Logger")),
                leftParen: .leftParenToken(),
                rightParen: .rightParenToken()
            ) {
                LabeledExprSyntax(label: "subsystem", expression: InfixOperatorExprSyntax(
                    leftOperand: DeclReferenceExprSyntax(baseName: .identifier("Bundle.main.bundleIdentifier")),
                    operator: BinaryOperatorExprSyntax(text: "??"),
                    rightOperand: StringLiteralExprSyntax(content: "")
                ))

                LabeledExprSyntax(label: "category", expression: StringLiteralExprSyntax(content: name))
            }
        )

        let binding = PatternBindingSyntax(
            pattern: pattern,
            typeAnnotation: typeAnnotation,
            initializer: initializer
        )

        let bindings = PatternBindingListSyntax([binding])

        return [
            DeclSyntax(
                VariableDeclSyntax(
                    leadingTrivia: documentationComment,
                    modifiers: modifiers,
                    bindingSpecifier: .keyword(.let),
                    bindings: bindings
                )
            )
        ]
    }
}
