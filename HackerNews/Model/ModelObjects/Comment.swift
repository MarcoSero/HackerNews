//
//  Post.swift
//  HackerNews
//
//  Created by Marco Sero on 09/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation

@objc public class Comment: NSObject, CustomDebugStringConvertible {
    
    public var commentId: String?
    public var username: String?
    public var timeString: String?
    public var body: String?
    public var level: Int = 0
    
    // MARK: Printable
    override public var description: String {
        return "\(timeString) by \(username) at level \(level):\n\(body)"
    }
    
    // MARK: DebugPrintable
    override public var debugDescription: String {
        return description
    }
    
}