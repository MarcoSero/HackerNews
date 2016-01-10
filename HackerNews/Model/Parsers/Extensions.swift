//
//  Extensions.swift
//  HackerNews
//
//  Created by Marco Sero on 15/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation


// MARK Safe Arrays - Thanks Mike Ash
extension Array {
  
    subscript (safe index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
  
}

// MARK String Subscript
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}

// MARK HTML Cleanup

let hrefRegex = try! NSRegularExpression(pattern: "<a[^>]+href=\"(.*?)\"[^>]*>.*?</a>", options: .CaseInsensitive)

let divRegex = try! NSRegularExpression(pattern: "<div.*?>(.|\n)*?</div>", options: .CaseInsensitive)

let htmlTagsRegex = try! NSRegularExpression(pattern: "<[^>]*>", options: .CaseInsensitive)

let asciiHTMLMap = [
    "&#38;" : "&",
    "&#62;" : ">",
    "&#x27;" : "'",
    "&#x2F;" : "/",
    "&quot;" : "\"",
    "&#60;" : "<",
    "&lt;" : "<",
    "&gt;" : ">",
    "&amp;" : "&"
]

extension String {
    
    func fromHackerNewsHTML() -> String {
        return self
            .removeDivs()
            .replaceParagraphsWithNewLines()
            .extractHrefs()
            .removeHTMLTags()
            .replaceHTMLCharacters()
            .trimCrap()
    }
    
    func removeDivs() -> String {
        return divRegex.stringByReplacingMatchesInString(self, options: [], range: NSMakeRange(0, self.characters.count), withTemplate: "")
    }
    
    func replaceParagraphsWithNewLines() -> String {
        return self.stringByReplacingOccurrencesOfString("<p>", withString:"\n", options:[], range:Range(start: self.startIndex, end: self.endIndex))
    }
    
    func extractHrefs() -> String {
        return hrefRegex.stringByReplacingMatchesInString(self, options: [], range: NSMakeRange(0, self.characters.count), withTemplate: "$1")
    }
    
    func removeHTMLTags() -> String {
        return htmlTagsRegex.stringByReplacingMatchesInString(self, options: [], range: NSMakeRange(0, self.characters.count), withTemplate: "")
    }
    
    func replaceHTMLCharacters() -> String {
        var newString = self
        for (htmlTag, asciiCharacter) in asciiHTMLMap {
            newString = newString.stringByReplacingOccurrencesOfString(htmlTag, withString:String(asciiCharacter), options:[], range:Range(start: newString.startIndex, end: newString.endIndex))
        }
        return newString
    }
    
    func trimCrap() -> String {
        return self
            .stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            .stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
}
