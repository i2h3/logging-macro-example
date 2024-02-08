import LoggingMacroExample
import Foundation
import os

@Logging
class Example {
    func sayHello() {
        logger.notice("Hello!")
    }
}

let example = Example()
example.sayHello()
