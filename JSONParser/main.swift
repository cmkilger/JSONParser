//
//  main.swift
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

import Foundation

if let data = NSData(contentsOfFile: "/Users/cmkilger/Desktop/users.json") {
    var start: NSDate
    var end: NSDate
    
    var obj: AnyObject? = nil
    start = NSDate()
    for i in 0 ..< 100 {
        obj = try? CKJSONSerialization.JSONObjectWithData(data, options: [])
//        sleep(1)
    }
    end = NSDate()
    print("CKJSONSerialization: \(end.timeIntervalSinceDate(start)) seconds")
    
    sleep(2)
    start = NSDate()
    for i in 0 ..< 100 {
        try? NSJSONSerialization.JSONObjectWithData(data, options: [])
    }
    end = NSDate()
    print("NSJSONSerialization: \(end.timeIntervalSinceDate(start)) seconds")
    
    print(obj)
} else {
    print("failed to load data")
}
