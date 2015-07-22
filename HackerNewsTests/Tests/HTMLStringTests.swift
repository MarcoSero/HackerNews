//
//  HTMLStringTests.swift
//  HackerNews
//
//  Created by Marco Sero on 08/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation
import XCTest

class HTMLStringTests: XCTestCase {
    
    func testThatAddsNewLines() {
        let htmlString = "<p>This is a paragraph</p>"
        XCTAssertEqual(htmlString.replaceParagraphsWithNewLines(), "\nThis is a paragraph</p>")
    }
    
    func testThatExtractsURL() {
        let URLString = "http://news.ycombinator.com"
        let htmlString = "<a href=\"\(URLString)\">helloooo</a>"
        XCTAssertEqual(htmlString.extractHrefs(), URLString)
    }
    
    func testThatRemovesHTMLTags() {
        let content = "hello"
        let htmlString = "<div class=\"coool\"><a href=\"nowhere\">\(content)</a></div>"
        XCTAssertEqual(htmlString.removeHTMLTags(), content)
    }
    
    func testThatReplacesHTMLCharacters() {
        let actualContent = "marco<>marco&sero.com"
        let htmlString = "marco&lt;&gt;marco&amp;sero.com"
        XCTAssertEqual(htmlString.replaceHTMLCharacters(), actualContent)
    }
    
    func testThatTrimsCrap() {
        let actualContent = "hello"
        let contentWithCrap = "\n\n\n   \n\nhello  \n\n\n\n\n"
        XCTAssertEqual(contentWithCrap.trimCrap(), actualContent)
    }
    
    func testThatDecodeHTMLFromHackerNews() {
        let html = "    \n\nThis is a link: <a href=\"http:www.marcosero.com\">LINK</a><p>This is the second paragraph</p>\n\n"
        let actualContent = "This is a link: http:www.marcosero.com\nThis is the second paragraph"
        XCTAssertEqual(html.fromHackerNewsHTML(), actualContent)
    }
    
}