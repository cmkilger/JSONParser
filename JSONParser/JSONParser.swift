//
//  JSONParser.swift
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

import Foundation

@objc
protocol JSONParserDelegate: class {
    optional func parserDidStartObject(parser: JSONParser)
    optional func parserDidEndObject(parser: JSONParser)
    optional func parserDidStartArray(parser: JSONParser)
    optional func parserDidEndArray(parser: JSONParser)
    optional func parser(parser: JSONParser, foundString: String)
    optional func parser(parser: JSONParser, foundNumber: NSNumber)
    optional func parserFoundTrue(parser: JSONParser)
    optional func parserFoundFalse(parser: JSONParser)
    optional func parserFoundNull(parser: JSONParser)
}

class JSONParser: NSObject {
    weak var delegate: JSONParserDelegate?
    
    func parseData(data: NSData) {
        var parser = json_parser()
        
        let startObject = UnsafeMutablePointer<(userInfo: UnsafeMutablePointer<Void>) -> Void>.alloc(1)
        startObject.initialize { (parser) -> Void in
            
        }
        parser.startObject = CFunctionPointer(COpaquePointer(startObject))
        
        
        let endObject = UnsafeMutablePointer<(userInfo: UnsafeMutablePointer<Void>) -> Void>.alloc(1)
        endObject.initialize { (parser) -> Void in
            
        }
        parser.endObject = CFunctionPointer(COpaquePointer(endObject))
        
        let startArray = UnsafeMutablePointer<(userInfo: UnsafeMutablePointer<Void>) -> Void>.alloc(1)
        startArray.initialize { (parser) -> Void in
            
        }
        parser.startArray = CFunctionPointer(COpaquePointer(startArray))
        
        let endArray = UnsafeMutablePointer<(userInfo: UnsafeMutablePointer<Void>) -> Void>.alloc(1)
        endArray.initialize { (parser) -> Void in
            
        }
        parser.endArray = CFunctionPointer(COpaquePointer(endArray))
        
        let foundString = UnsafeMutablePointer<(userInfo: UnsafeMutablePointer<Void>) -> Void>.alloc(1)
        foundString.initialize { (parser) -> Void in
            
        }
        parser.foundString = CFunctionPointer(COpaquePointer(foundString))
        
        let foundNumber = UnsafeMutablePointer<(userInfo: UnsafeMutablePointer<Void>) -> Void>.alloc(1)
        foundNumber.initialize { (parser) -> Void in
            
        }
        parser.foundNumber = CFunctionPointer(COpaquePointer(foundNumber))
        
        let foundTrue = UnsafeMutablePointer<(userInfo: UnsafeMutablePointer<Void>) -> Void>.alloc(1)
        foundTrue.initialize { (parser) -> Void in
            
        }
        parser.foundTrue = CFunctionPointer(COpaquePointer(foundTrue))
        
        let foundFalse = UnsafeMutablePointer<(userInfo: UnsafeMutablePointer<Void>) -> Void>.alloc(1)
        foundFalse.initialize { (parser) -> Void in
            
        }
        parser.foundFalse = CFunctionPointer(COpaquePointer(foundFalse))
        
        let foundNull = UnsafeMutablePointer<(userInfo: UnsafeMutablePointer<Void>) -> Void>.alloc(1)
        foundNull.initialize { (parser) -> Void in
            
        }
        parser.foundNull = CFunctionPointer(COpaquePointer(foundNull))
    }
}
