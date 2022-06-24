//
//  main.swift
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

import Foundation

let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

var start: Date
var end: Date

let iterations = 1000

start = Date()
for _ in 0 ..< iterations {
    _ = try CKJSONSerialization.jsonObject(with: data, options: [])
}
end = Date()
print("CKJSONSerialization: \(end.timeIntervalSince(start)) seconds")

sleep(2)

start = Date()
for _ in 0 ..< iterations {
    _ = try JSONSerialization.jsonObject(with: data, options: [])
}
end = Date()
print("NSJSONSerialization: \(end.timeIntervalSince(start)) seconds")
