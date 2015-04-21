//
//  main.swift
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

import Foundation

if let data = NSData(contentsOfFile: "/Users/cmkilger/Desktop/details.json") {
    var start: NSDate
    var end: NSDate
    
    var obj: AnyObject? = nil
    start = NSDate()
    for i in 0 ..< 100 {
        obj = CKJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
//        sleep(1)
    }
    end = NSDate()
    println("CKJSONSerialization: \(end.timeIntervalSinceDate(start)) seconds")
    
    sleep(2)
    start = NSDate()
    for i in 0 ..< 100 {
        NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
    }
    end = NSDate()
    println("NSJSONSerialization: \(end.timeIntervalSinceDate(start)) seconds")
    
    println(obj)
} else {
    println("failed to load data")
}
