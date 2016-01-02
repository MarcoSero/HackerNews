//
//  Client.swift
//  HackerNews
//
//  Created by Marco Sero on 15/05/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import FXReachability

func stringFromData(data: NSData) -> Result<String, NSError> {
    if let s = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
        return Result.success(s)
    }
    return Result.failure(NSError(domain: "com.marcosero.HackerNews", code: 1, userInfo: [ NSLocalizedDescriptionKey: "Can't get string from data" ]))
}

typealias HtmlParser = String -> Result<NSObject, NSError>

let HackerNewsURL = NSURL(string: "https://news.ycombinator.com")!

@objc public class Client: NSObject {
    
    let scheduler = RACScheduler(priority: RACSchedulerPriorityBackground)
    let baseURL = HackerNewsURL.absoluteString
    
    public var reachabilitySignal: RACSignal {
        let reachability = FXReachability.sharedInstance()
        return
            NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(FXReachabilityStatusDidChangeNotification, object: nil)
                .map{ (notification) -> AnyObject! in
                    let reachabilityObj = notification.object as! FXReachability
                    return reachabilityObj.isReachable()
                }
                .distinctUntilChanged()
                .startWith(reachability.isReachable())
    }
    
    public func postsWithType(type: PostType, page: Int = 1) -> RACSignal? {
        if let newType = PostType(rawValue: type.rawValue) {
            let URL = NSURL(string: "\(baseURL)/\(newType.httpPath())?p=\(page)")!
            let parser: HtmlParser = PostsParser.fromHTML(postsType: newType)
            let signalProducer = getHTMLFromURL(URL, parseHtml: parser)
            return toRACSignal(signalProducer)
        }
        return nil
    }
    
    public func getCommentsForPost(post: Post) -> RACSignal {
        let URL = NSURL(string: "\(baseURL)/item?id=\(post.postID!)")!
        let parser = CommentsParser.fromHTML(commentCount: post.commentCount)
        let signalProducer = getHTMLFromURL(URL, parseHtml: parser)
        return toRACSignal(signalProducer)
    }
    
    public func getUserWithUsername(username: String) -> RACSignal {
        let URL = NSURL(string: "\(baseURL)/user?id=\(username)")!
        let signalProducer = getHTMLFromURL(URL, parseHtml: UserParser.fromHTML)
        return toRACSignal(signalProducer)
    }
    
    // MARK - Private
    
    func getHTMLFromURL(URL: NSURL, parseHtml: HtmlParser) -> SignalProducer<NSObject, NSError> {
        let request = NSURLRequest(URL: URL)
        return NSURLSession.sharedSession().rac_dataWithRequest(NSURLRequest(URL: URL))
            |> map { data, _ in data } // ignore NSURLResponse
            |> tryMap(stringFromData)
            |> tryMap(parseHtml)
    }
    
}