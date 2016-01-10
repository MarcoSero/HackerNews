//
//  Parsers.swift
//  HackerNews
//
//  Created by Marco Sero on 17/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

public struct PostsParser {
    
    public static func fromHTML(postsType postsType: PostType)(html: String) -> Result<NSObject, NSError> {
        var error: NSError?
        let parser = HTMLParser(html: html, error: &error)
        if let error = error {
            return Result.Failure(NSError(domain: error.domain, code: error.code, userInfo: error.userInfo))
        }
        
        var posts: [Post] = []
        
        let bodyNode = parser.body
        let headers = bodyNode?.xpath("//td[@class='title' and a]")
        let footers = bodyNode?.xpath("//td[@class='subtext']")
        
        let isValid = (headers != nil) && (footers != nil) && (footers!.count <= headers!.count)
        assert(isValid, "Post headers must match footers")
        
        if !isValid {
            return Result.Failure(NSError(domain: "com.marcosero.HackerNews", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Parsing error"
                ]))
        }
        
        let titleNodes = headers!.map { $0.xpath("a")?.first }
        let titles = titleNodes.map { $0?.contents }
        let URLs = titleNodes.map { titleNode -> NSURL? in
            if let urlString = titleNode?.xpath("@href")?.first?.contents {
                return NSURL(string: urlString)
            }
            return nil
        }
        let domains = headers!
            .map { $0.xpath("span/a/span[@class='sitestr']")?.first?.contents
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }

        let points = footers!
            .map { $0.xpath("span[@class='score']")?.first?.contents }
            .map { $0?.stringByReplacingOccurrencesOfString(" points", withString: "", options: .CaseInsensitiveSearch, range: nil) }
            .map { Int($0 ?? "0") }
      
        let footersLinks = footers!.map { $0.xpath("a") }
        let usernames = footersLinks.map { $0?[safe:0]?.contents }
        let timeStrings = footers!.map { $0.xpath("span[@class='age']/a")?.first?.contents }
        let postIDs = footersLinks
            .map { $0?[safe:1]?.xpath("@href")?.first?.contents }
            .map { s -> String? in
                if let s = s {
                    return s[8 ..< s.characters.count]
                }
                return nil
            }
      
        let commentCounts = footersLinks
            .map { $0?[safe:1]?.contents }
            .map { $0?.stringByReplacingOccurrencesOfString(" comments", withString: "", options: .CaseInsensitiveSearch, range: nil) }
            .map { Int($0 ?? "0") }
      
        for i in 0..<footers!.count {
            let post = Post()
            post.postID = postIDs[i]
            post.username = usernames[i]
            post.timeString = timeStrings[i]
            post.title = titles[i]
            post.URL = URLs[i]
            post.domain = domains[i]
            post.points = points[i] != nil ? points[i]! : 0
            post.commentCount = commentCounts[i] != nil ? commentCounts[i]! : 0
            post.type = postsType
            posts.append(post)
        }
        
        return Result.Success(posts)
    }
}
