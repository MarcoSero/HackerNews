//
//  PostsParserTests.swift
//  HackerNews
//
//  Created by Marco Sero on 14/07/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation
import XCTest
import HackerNews

class PostsParserTests : XCTestCase {
    
    var stub: String = ""
    let expectedPosts = 30
    
    override func setUp() {
        let bundle = NSBundle(forClass: PostsParserTests.self)
        let path = bundle.pathForResource("front-page", ofType: "html")
        stub = String(contentsOfFile:path!, encoding: NSUTF8StringEncoding, error: nil)!
    }
    
    func testPostsParserWithStub() {
        let result = PostsParser.fromHTML(postsType: .Popular)(html: stub)
        
        switch result {
        case let .Success(box) where box.value is [Post]:
            let posts = box.value as! [Post]
            XCTAssertEqual(count(posts), expectedPosts, "Should parse \(expectedPosts) posts")
        default:
            XCTFail("Parsing error")
        }
        
    }
    
}