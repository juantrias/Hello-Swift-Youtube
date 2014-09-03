// Playground - noun: a place where people can play

import UIKit

// Big Fail: we have to copy here in the Playground the contents of the Regex.swift file because the Playgrounds run on a sandbox environment isolated from the rest of the Project and cannot access the project classes. To use "import" we would have to build a framwork with the classes we want to use :'(
// http://stackoverflow.com/questions/24045245/how-to-import-own-classes-from-your-own-project-into-a-playground/24049021#24049021

infix operator =~ {}

func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, countElements(input)))
        return matches.count > 0
    }
}

// Testing Regex while we write. Awesome!
var nonNegativeIntRegex = "^[0-9]+$"
"0" =~ nonNegativeIntRegex
"12" =~ nonNegativeIntRegex
"437389467356" =~ nonNegativeIntRegex
"-1" =~ nonNegativeIntRegex
"a" =~ nonNegativeIntRegex
"1a" =~ nonNegativeIntRegex
"" =~ nonNegativeIntRegex
