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
        stub = try! String(contentsOfFile:path!, encoding: NSUTF8StringEncoding)
    }
    
    func testPostsParserWithStub() {
        let result = PostsParser.fromHTML(postsType: .Popular)(html: stub)
        
        switch result {
        case let .Success(box) where box is [Post]:
            let posts = box as! [Post]
            XCTAssertEqual(posts.count, expectedPosts, "Should parse \(expectedPosts) posts")
          
            let firstPost = posts.first
            AssertEqualOptional(firstPost?.postID, "10860517")
            AssertEqualOptional(firstPost?.username, "brahmwg")
            AssertEqualOptional(firstPost?.timeString, "8 hours ago")
            AssertEqualOptional(firstPost?.title, "Valuing time over money is associated with greater happiness")
            AssertEqualOptional(firstPost?.URL, "https://www.researchgate.net/publication/283619534_Valuing_time_over_money_is_associated_with_greater_happiness")
            AssertEqualOptional(firstPost?.domain, "researchgate.net")
            AssertEqualOptional(firstPost?.points, 317)
            AssertEqualOptional(firstPost?.commentCount, 121)
            AssertEqualOptional(firstPost?.type, .Popular)

        default:
            XCTFail("Parsing error")
        }
        
    }
    
}