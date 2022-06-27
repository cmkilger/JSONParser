//
//  main.swift
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

import Foundation
import JSONParsing

let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

//var start: Date
//var end: Date
//
//let iterations = 1000
//
//start = Date()
//for _ in 0 ..< iterations {
//    _ = try CKJSONSerialization.jsonObject(with: data, options: [])
//}
//end = Date()
//print("CKJSONSerialization: \(end.timeIntervalSince(start)) seconds")
//
//sleep(2)
//
//start = Date()
//for _ in 0 ..< iterations {
//    _ = try JSONSerialization.jsonObject(with: data, options: [])
//}
//end = Date()
//print("NSJSONSerialization: \(end.timeIntervalSince(start)) seconds")

//JSONLineNumber.parseData(data)

//print(JSONPath(from: "/group/items/6/action/url", in: try JSONSerialization.jsonObject(with: data, options: [])))
//print(JSONPath(from: "group.items[6].action.url"))

print(try JSONFindPath.position(for: JSONPath(from: "group.items[6].action.url")!, in: data) ?? "nil")
//print(try JSONFindPath.position(for: JSONPath(from: "[2]")!, in: #"[1, 2, 3]"#.data(using: .utf8)!))
