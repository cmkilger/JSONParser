//
//  CKJSONSerialization.swift
//  JSONParser
//
//  Created by Cory Kilger on 4/21/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

import Foundation

class CKJSONSerialization: NSObject, JSONParserDelegate {
    private var root: AnyObject?
    private var currentKey: String?
    private var containers = [AnyObject]()
    
    class func JSONObjectWithData(data: NSData, options opt: NSJSONReadingOptions, error: NSErrorPointer) -> AnyObject? {
        let parser = JSONParser()
        let treeParser = CKJSONSerialization()
        parser.delegate = treeParser
        parser.parseData(data, error: error)
        return treeParser.root
    }
    
    
    // MARK: - Parser delegate
    
    func parserDidStartObject(parser: JSONParser) {
        let object = NSMutableDictionary()
        var container: AnyObject? = containers.last
        if let key = currentKey where (container as? NSMutableDictionary) != nil {
            var containerObject = container as! NSMutableDictionary
            containerObject[key] = object
            currentKey = nil
        } else if (container as? NSMutableArray) != nil {
            var containerArray = container as! NSMutableArray
            containerArray.addObject(object)
        } else if root == nil {
            root = object
        }
        containers.append(object)
    }
    
    func parserDidEndObject(parser: JSONParser) {
        containers.removeLast()
    }
    
    func parserDidStartArray(parser: JSONParser) {
        let array = NSMutableArray()
        var container: AnyObject? = containers.last
        if let key = currentKey where (container as? NSMutableDictionary) != nil {
            var containerObject = container as! NSMutableDictionary
            containerObject[key] = array
            currentKey = nil
        } else if (container as? NSMutableArray) != nil {
            var containerArray = container as! NSMutableArray
            containerArray.addObject(array)
        } else if root == nil {
            root = array
        }
        containers.append(array)
    }
    
    func parserDidEndArray(parser: JSONParser) {
        containers.removeLast()
    }
    
    func parser(parser: JSONParser, foundString string: String) {
        var container: AnyObject? = containers.last
        if (container as? NSMutableDictionary) != nil {
            if let key = currentKey {
                var containerObject = container as! NSMutableDictionary
                containerObject[key] = string
                currentKey = nil
            } else {
                currentKey = string
            }
        } else if (container as? NSMutableArray) != nil {
            var containerArray = container as! NSMutableArray
            containerArray.addObject(string)
        } else {
            root = string
        }
    }
    
    func parser(parser: JSONParser, foundNumber number: NSNumber) {
        var container: AnyObject? = containers.last
        if let key = currentKey where (container as? NSMutableDictionary) != nil {
            var containerObject = container as! NSMutableDictionary
            containerObject[key] = number
            currentKey = nil
        } else if (container as? NSMutableArray) != nil {
            var containerArray = container as! NSMutableArray
            containerArray.addObject(number)
        } else {
            root = number
        }
    }
    
    func parserFoundTrue(parser: JSONParser) {
        var container: AnyObject? = containers.last
        if let key = currentKey where (container as? NSMutableDictionary) != nil {
            var containerObject = container as! NSMutableDictionary
            containerObject[key] = true
            currentKey = nil
        } else if (container as? NSMutableArray) != nil {
            var containerArray = container as! NSMutableArray
            containerArray.addObject(true)
        } else {
            root = true
        }
    }
    
    func parserFoundFalse(parser: JSONParser) {
        var container: AnyObject? = containers.last
        if let key = currentKey where (container as? NSMutableDictionary) != nil {
            var containerObject = container as! NSMutableDictionary
            containerObject[key] = false
            currentKey = nil
        } else if (container as? NSMutableArray) != nil {
            var containerArray = container as! NSMutableArray
            containerArray.addObject(false)
        } else {
            root = false
        }
    }
    
    func parserFoundNull(parser: JSONParser) {
        var container: AnyObject? = containers.last
        if let key = currentKey where (container as? NSMutableDictionary) != nil {
            var containerObject = container as! NSMutableDictionary
            containerObject[key] = NSNull()
            currentKey = nil
        } else if (container as? NSMutableArray) != nil {
            var containerArray = container as! NSMutableArray
            containerArray.addObject(NSNull())
        } else {
            root = NSNull()
        }
    }
}
