//
//  CommentsParserTests.swift
//  HackerNews
//
//  Created by Marco Sero on 14/07/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation
import XCTest
import HackerNews

class CommentsParserTests : XCTestCase {
    
    var stub: String = ""
    let expectedComments = 51
    
    override func setUp() {
        let bundle = NSBundle(forClass: CommentsParserTests.self)
        let path = bundle.pathForResource("post-page", ofType: "html")
        stub = try! String(contentsOfFile:path!, encoding: NSUTF8StringEncoding)
    }
    
    func testComments() {
        let result = CommentsParser.fromHTML(commentCount: expectedComments)(html: stub)
        
        switch result {
        case let .Success(box) where box.value is [Comment]:
            
            let comments = box.value as! [Comment]
            assert(comments.count == expectedComments, "Should parse \(expectedComments) comments")
            
            let firstComment = comments.first
            AssertEqualOptional(firstComment?.commentId, "9884723")
            AssertEqualOptional(firstComment?.timeString, "31 minutes ago")
            AssertEqualOptional(firstComment?.username, "Arjuna")
            AssertEqualOptional(firstComment?.body, "In honor of Clyde William Tombaugh [1], the astronomer who discovered Pluto, a canister [2] containing his ashes is on-board the New Horizons space probe. It reads:\n\"Interned herein are remains of American Clyde W. Tombaugh, discoverer of Pluto and the Solar System's 'Third Zone.' Adelle and Muron's boy, Patricia's husband, Annette and Alden's father, astronomer, teacher, punster, and friend: Clyde W. Tombaugh (1906 - 1997).\"\n\nA fitting tribute.\n\n[1] https://en.wikipedia.org/wiki/Clyde_Tombaugh\n\n[2] http://media2.s-nbcnews.com/j/newscms/2015_28/1109391/150706-ashes_7dd0a2249a8eb96eedd34f0c5687f931.nbcnews-fp-360-360.jpg")
            AssertEqualOptional(firstComment?.level, 0)
            
            let lastComment = comments.last
            AssertEqualOptional(lastComment?.commentId, "9884661")
            AssertEqualOptional(lastComment?.timeString, "39 minutes ago")
            AssertEqualOptional(lastComment?.username, "chasing")
            AssertEqualOptional(lastComment?.body, "This is awesome. Congratulations to everyone who pulled this off (and fingers crossed that the data gets back successfully).\nEveryone has earned the right to chant the name of whatever country they feel like.")
            AssertEqualOptional(lastComment?.level, 0)
            
        default:
            XCTFail("Parsing error")
        }
    }
    
}
