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

public struct CommentsParser {

    public static func fromHTML(#commentCount: Int)(html: String) -> Result<NSObject, NSError> {
        var error: NSError?
        var parser = HTMLParser(html: html, error: &error)
        if let error = error {
            return Result.failure(error)
        }
        
        var comments: [Comment] = []
        
        let bodyNode = parser.body
        let commentHeads = bodyNode?.xpath("//span[@class='comhead']")
        let commentBodies = bodyNode?.xpath("//span[@class='comment']")
        let indentations = bodyNode?.xpath("//td[@class='ind']/img/@width")
        
        let isValid = (commentHeads != nil) && (commentBodies != nil) && (indentations != nil) && (commentHeads?.count == commentBodies?.count) && (commentHeads?.count == indentations?.count)
        
        if !isValid {
            if commentCount == 0 {
                return Result.success(comments)
            }
            assert(false, "Comments heads count must match bodies count")
            return Result.failure(NSError(domain: "com.marcosero.HackerNews", code: 1, userInfo: [ NSLocalizedDescriptionKey: "Parsing error" ]))
        }
        
        let commentInfos = commentHeads?.map{ $0.xpath("a") }
        let usernames = commentInfos?.map { $0?.first?.contents }
        let timeStrings = commentInfos?.map { $0?[safe:1]?.contents }
        let bodies = commentBodies?.map { $0.rawContents.fromHackerNewsHTML() }
        let commentIds = commentInfos?
            .map { $0?[safe:1]?.xpath("@href")?.first?.contents }
            .map { s -> String? in
                if let s = s {
                    return s[8 ..< count(s)]
                }
                return nil
            }
        let levels = indentations?
            .map { $0.contents.toInt() }
            .map { level -> Int in
                if let level = level {
                    return level / 40
                }
                return 0
            }
        
        for i in 0..<commentHeads!.count {
            let comment = Comment()
            comment.username = usernames?[i]
            comment.timeString = timeStrings?[i]
            comment.commentId = commentIds?[i]
            comment.body = bodies?[i]
            if let l = levels?[i] {
                comment.level = l
            }
            comments.append(comment)
        }

        return Result.success(comments)
    }
}
