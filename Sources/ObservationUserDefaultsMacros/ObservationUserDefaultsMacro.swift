import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservationUserDefaultsMacro {}

// MARK: - Peer Macro

extension ObservationUserDefaultsMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let varDecl = try variableDecl(declaration)
        let name = try name(from: varDecl)
        let type = try type(from: varDecl)

        let decl = """
            @ObservationIgnored
            private let _\(raw: name): ObservationUserDefaultsController<\(raw: type)>
            """ as DeclSyntax
        return [decl]
    }
}

extension ObservationUserDefaultsMacro {
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
        if let type = varDecl.bindings.first?.typeAnnotation?.type.trimmedDescription  {
            return type
        }
        throw DiagnosticsError(node: Syntax(varDecl), message: .invalidTypeAnnotation)
    }
}

// MARK: - Accessor Macro

extension ObservationUserDefaultsMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let varDecl = try variableDecl(declaration)
        let name = try name(from: varDecl)
        let type = try type(from: varDecl)
        let arguments = try arguments(from: node)
        let keyExpr = try keyExpr(from: arguments)
        let storeExpr = try userDefaultsExpr(from: arguments)
        return [
            """
            @storageRestrictions(initializes: _\(raw: name))
            init(initialValue) {
                _\(raw: name) = ObservationUserDefaultsController<\(raw: type)>(userDefaults: \(storeExpr), key: \(keyExpr), initialValue: initialValue)
            }
            """,
            """
            get {
                _\(raw: name).withinObservation(mutation: { [weak self] in
                    self?.withMutation(keyPath: \\.\(raw: name)) {}
                })
                access(keyPath: \\.\(raw: name))
                return _\(raw: name).getValue()
            }
            """,
            """
            set {
               _\(raw: name).setValue(newValue)
            }
            """,
        ]
    }

    private static func arguments(from node: AttributeSyntax) throws -> LabeledExprListSyntax {
        guard let args = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw DiagnosticsError(node: Syntax(node), message: .invalidAttributeArguments)
        }
        return args
    }

    private static func keyExpr(from arguments: LabeledExprListSyntax) throws -> ExprSyntax {
        guard let expr = arguments.first?.as(LabeledExprSyntax.self)?.expression else {
            throw DiagnosticsError(node: Syntax(arguments), message: .invalidAttributeArguments)
        }
        return expr
    }

    private static func userDefaultsExpr(from arguments: LabeledExprListSyntax) throws -> ExprSyntax {
        guard arguments.count > 1 else { return ".standard" }
        let index = arguments.index(after: arguments.startIndex)
        guard let expr = arguments[index].as(LabeledExprSyntax.self)?.expression else {
            throw DiagnosticsError(node: Syntax(arguments[index]), message: .invalidAttributeArguments)
        }
        return expr
    }
}

// MARK: - Diagnostics Error

enum ObservationUserDefaultsMacrosDiagnostic: DiagnosticMessage {
    case notVariableProperty
    case invalidPatternName
    case invalidTypeAnnotation
    case invalidAttributeArguments

    var severity: DiagnosticSeverity { .error }

    var message: String {
        switch self {
        case .notVariableProperty:
            "Macro 'ObservableUserDefaults' is for variable properties only"
        case .invalidPatternName:
            "Invalid pattern"
        case .invalidTypeAnnotation:
            "Required valid type annotation in pattern"
        case .invalidAttributeArguments:
            "Invalid arguments"
        }
    }

    var diagnosticID: MessageID { .init(domain: "UserDefaultsMacro", id: message) }
}

fileprivate extension DiagnosticsError {
    init(node: Syntax, message: ObservationUserDefaultsMacrosDiagnostic) {
        self.init(diagnostics: [.init(node: node, message: message)])
    }
}

// MARK: - Plugin

@main
struct ObservationUserDefaultsMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObservationUserDefaultsMacro.self,
    ]
}
