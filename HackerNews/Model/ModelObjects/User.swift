//
//  User.swift
//  HackerNews
//
//  Created by Marco Sero on 25/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation

@objc public class User: NSObject, CustomDebugStringConvertible {
    
    public var username: String?
    public var karma: Int = 0
    public var about: String?
    public var createdString: String?
    
    // MARK: Printable
    override public var description: String {
        return "\(username) | \(karma) karma | about: \(about)"
    }
    
    // MARK: DebugPrintable
    override public var debugDescription: String {
        return description
    }
    
}