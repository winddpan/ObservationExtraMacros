import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - Peer Macro

public struct ObservationQueryMacro: PeerMacro, AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let varDecl = try variableDecl(declaration)
        let name = try name(from: varDecl)
        let type = try type(from: varDecl)
        let arguments = arguments(from: node)

        let decl: DeclSyntax = """
            @ObservationIgnored 
            private let _\(raw: name) = ObservationQueryController<\(raw: type)>(\(raw: arguments ?? ""))
            """

        return [decl]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let varDecl = try variableDecl(declaration)
        let name = try name(from: varDecl)
        return [
            """
            get {
                _\(raw: name).withinObservation(mutation: { [weak self] mutation in
                    self?.withMutation(keyPath: \\.\(raw: name)) {
                        mutation()
                    }
                })
                access(keyPath: \\.\(raw: name))
                return _\(raw: name).results
            }
            """
        ]
    }
}

extension ObservationQueryMacro {
    private static func variableDecl(_ declaration: some DeclSyntaxProtocol) throws -> VariableDeclSyntax {
        guard let varDecl = declaration.as(VariableDeclSyntax.self), varDecl.bindingSpecifier.text == "var" else {
            throw DiagnosticsError(node: Syntax(declaration), message: .notVariableProperty)
        }
        return varDecl
    }

    private static func name(from varDecl: VariableDeclSyntax) throws -> String {
        guard let name = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw DiagnosticsError(node: Syntax(varDecl), message: .invalidPatternName)
        }
        return name
    }

    private static func type(from varDecl: VariableDeclSyntax) throws -> String {
        guard
            let type = varDecl.bindings.first?.typeAnnotation?.type.as(ArrayTypeSyntax.self)?.element.as(
                IdentifierTypeSyntax.self)?.name.text
        else {
            throw DiagnosticsError(node: Syntax(varDecl), message: .invalidTypeAnnotation)
        }
        return type
    }

    private static func arguments(from node: AttributeSyntax) -> String? {
        guard let args = node.arguments?.as(LabeledExprListSyntax.self) else {
            return nil
        }
        return args.trimmedDescription
    }
}

// MARK: - Diagnostics Error

enum ObservationQueryMacrosDiagnostic: DiagnosticMessage {
    case notVariableProperty
    case invalidPatternName
    case invalidTypeAnnotation

    var severity: DiagnosticSeverity { .error }

    var message: String {
        switch self {
        case .notVariableProperty:
            "Macro 'ObservableUserDefaults' is for variable properties only"
        case .invalidPatternName:
            "Invalid pattern"
        case .invalidTypeAnnotation:
            "Required valid type annotation in pattern"
        }
    }

    var diagnosticID: MessageID { .init(domain: "ObservationUserDefaultsMacro", id: message) }
}

extension DiagnosticsError {
    fileprivate init(node: Syntax, message: ObservationQueryMacrosDiagnostic) {
        self.init(diagnostics: [.init(node: node, message: message)])
    }
}

// MARK: - Plugin

@main
struct ObservationQueryMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObservationQueryMacro.self
    ]
}
