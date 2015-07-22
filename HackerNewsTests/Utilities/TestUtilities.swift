//
//  TestUtilities.swift
//  HackerNews
//
//  Created by Marco Sero on 16/07/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation
import XCTest

// Snippet from https://blog.codecentric.de/en/2014/10/extending-xctestcase-testing-swift-optionals/

extension XCTestCase {
    
    func AssertEqualOptional<T : Equatable>(@autoclosure theOptional: () -> T?, @autoclosure _ expression2: () -> T, file: String = __FILE__, line: UInt = __LINE__) {
        if let e = theOptional() {
            let e2 = expression2()
            if e != e2 {
                self.recordFailureWithDescription("Optional (\(e)) is not equal to (\(e2))", inFile: file, atLine: line, expected: true)
            }
        }
        else {
            self.recordFailureWithDescription("Optional value is empty", inFile: file, atLine: line, expected: true)
        }
    }
    
}
