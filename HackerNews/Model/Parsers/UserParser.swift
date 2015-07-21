//
//  UserParser.swift
//  HackerNews
//
//  Created by Marco Sero on 17/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

struct UserParser {
    
    static func fromHTML(html: String) -> Result<NSObject, NSError> {
        var error: NSError?
        var parser = HTMLParser(html: html, error: &error)
        if let error = error {
            return Result.failure(NSError(domain: error.domain, code: error.code, userInfo: error.userInfo))
        }
        
        let bodyNode = parser.body
        
        let user = User()
        user.username = bodyNode?.xpath("//td[contains(text(),'user:')]")?.first?.next?.contents
        user.karma = bodyNode?.xpath("//td[contains(text(),'karma:')]")?.first?.next?.contents.toInt() ?? 0
        user.createdString = bodyNode?.xpath("//td[contains(text(),'created:')]")?.first?.next?.contents
        user.about = bodyNode?.xpath("//td[contains(text(),'about:')]")?.first?.next?.rawContents.fromHackerNewsHTML()

        return Result.success([user])
    }
}
