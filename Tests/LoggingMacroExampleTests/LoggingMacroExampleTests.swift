import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(LoggingMacroExampleMacros)
import LoggingMacroExampleMacros

let testMacros: [String: Macro.Type] = [
    "Logging": LoggingMacro.self,
]
#endif

final class LoggingMacroExampleTests: XCTestCase {
    func testLoggingMacro() throws {
        #if canImport(LoggingMacroExampleMacros)
        assertMacroExpansion(
                #"""
                @Logging
                class Example {
                }
                """#,
                expandedSource: #"""
                class Example {

                    /// Specific `Logger` for this instance of ``Example``.
                    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "Example")
                }
                """#,
                macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testLoggingMacroOnEnum() throws {
        #if canImport(LoggingMacroExampleMacros)
        assertMacroExpansion(
                #"""
                @Logging
                enum Example {
                }
                """#,
                expandedSource: #"""
                enum Example {

                    /// Specific `Logger` for this instance of ``Example``.
                    static let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "Example")
                }
                """#,
                macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
