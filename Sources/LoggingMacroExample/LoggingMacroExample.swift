///
/// Automatically sets up a `Logger` object accessible through the automatically added `logger` property.
///
/// This macro requires the `os` framework to be imported.
///
@attached(member, names: named(logger))
public macro Logging() = #externalMacro(module: "LoggingMacroExampleMacros", type: "LoggingMacro")
