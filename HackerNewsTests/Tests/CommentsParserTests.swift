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
    let expectedComments = 121
    
    override func setUp() {
        let bundle = NSBundle(forClass: CommentsParserTests.self)
        let path = bundle.pathForResource("post-page", ofType: "html")
        stub = try! String(contentsOfFile:path!, encoding: NSUTF8StringEncoding)
    }
    
    func testComments() {
        let result = CommentsParser.fromHTML(commentCount: expectedComments)(html: stub)
        
        switch result {
        case let .Success(box) where box is [Comment]:

            let comments = box as! [Comment]
            assert(comments.count == expectedComments, "Should parse \(expectedComments) comments")

            let firstComment = comments.first
            AssertEqualOptional(firstComment?.commentId, "10860901")
            AssertEqualOptional(firstComment?.timeString, "7 hours ago")
            AssertEqualOptional(firstComment?.username, "roymurdock")
            AssertEqualOptional(firstComment?.body, "I searched for the phrase \"diminishing marginal returns\" but could not find it in the article which seems like a bit of an omission.\nThis is a fundamental economic concept - the more of something you have, the less value you derive from each incremental unit.\n\nSo, based on personal preferences, once you reach a certain level of income you will start to substitute away from labor (income) towards leisure/free time (non-market activities such as hobbies, cooking, parenting, gaming, chilling).\n\nThe study data shows this pretty clearly (if I'm reading it correctly) - in Study 2b (wealthy people polled at a science museum) the median household income was $100-149k and the \"% Time Oriented\" was 69%. In Study 4 (online panel members who get free internet in exchange for survey participation) the median household income was $75-85k and the \"% Time Oriented\" was 46%.\n\nThe implied result that upper middle class folk are able to spend more time on leisure and are therefore happier on average than regular middle class folk doesn\'t seem too groundbreaking.")
            AssertEqualOptional(firstComment?.level, 0)
            
            let lastComment = comments.last
            AssertEqualOptional(lastComment?.commentId, "10861318")
            AssertEqualOptional(lastComment?.timeString, "6 hours ago")
            AssertEqualOptional(lastComment?.username, "spectrum1234")
            AssertEqualOptional(lastComment?.body, "But I thought time IS money ?????")
            AssertEqualOptional(lastComment?.level, 0)
            
        default:
            XCTFail("Parsing error")
        }
    }
    
}
