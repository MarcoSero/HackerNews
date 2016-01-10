//
//  Post.swift
//  HackerNews
//
//  Created by Marco Sero on 09/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation

@objc public enum PostType: Int {
    case Popular = 1
    case New
    case Show
    case Ask
    case Jobs
    
    static var allTypes: [String] {
        var allTypes: [String] = []
        for i in PostType.Popular.rawValue...PostType.Jobs.rawValue {
            allTypes.append(PostType(rawValue: i)!.prettyString())
        }
        return allTypes
    }
    
    func httpPath() -> String {
        switch(self) {
        case .Popular: return "news"
        case .New: return "newest"
        case .Show: return "show"
        case .Ask: return "ask"
        case .Jobs: return "jobs"
        }
    }
    
    func prettyString() -> String {
        switch(self) {
        case .Popular: return "Popular"
        case .New: return "New"
        case .Show: return "Show"
        case .Ask: return "Ask"
        case .Jobs: return "Jobs"
        }
    }
}

@objc public class Post: NSObject, CustomDebugStringConvertible {
    
    public var postID: String?
    public var username: String?
    public var timeString: String?
    public var title: String?
    public var points: Int = 0
    public var URL: NSURL?
    public var domain: String?
    public var commentCount: Int = 0
    public var comments: [Comment]?
    public var type: PostType = .Popular
    public var postTypeString: String {
        return type.prettyString()
    }
    
    // MARK: Obj-C bridge
    public static var allPossibleTypes: [String] {
        return PostType.allTypes
    }
    
    public static func prettyStringForType(type: PostType) -> String {
        return type.prettyString()
    }
    
    // MARK: Printable
    override public var description: String {
        return "\(title) - \(timeString) by \(username) points \(points)"
    }
    
    // MARK: DebugPrintable
    override public var debugDescription: String {
        return description
    }
}

public extension Post {
    
    var isHackerNewsThread: Bool {
        let isSpecialHackerNewsURL = URL?.absoluteString.hasPrefix("item?")
        return URL?.host == HackerNewsURL.host ||
                isSpecialHackerNewsURL == nil ||
                isSpecialHackerNewsURL!
    }
    
}