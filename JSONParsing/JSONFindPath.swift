//
//  JSONFindPath.swift
//  JSONParser
//
//  Created by Cory Kilger on 6/24/22.
//  Copyright © 2022 Cory Kilger. All rights reserved.
//

import Cocoa

public struct JSONPath: Equatable, CustomDebugStringConvertible {
    public enum Component: Equatable, CustomDebugStringConvertible {
        case key(String)
        case index(Int)
        
        public var debugDescription: String {
            switch self {
            case .key(let key): return key
            case .index(let index): return "[\(index)]"
            }
        }
    }
    
    public var components: [Component]
    
    public init(components: [Component]) {
        self.components = components
    }
    
    private static let indexRegex = try! NSRegularExpression(pattern: #"\[(\d+)\]"#)
    
    /// `string` is in the format like `"group.items[6].action.url"`
    public init?(from string: String) {
        var components = [Component]()
        for key in string.components(separatedBy: ".") {
            if let key = key.components(separatedBy: "[").first, !key.isEmpty {
                components.append(.key(key))
            }
            for match in Self.indexRegex.matches(in: key, range: NSRange(location: 0, length: key.utf16.count)) {
                guard let index = Int((key as NSString).substring(with: match.range(at: 1))) else { return nil }
                components.append(.index(index))
            }
        }
        self.components = components
    }
          
    /// `string` is in the format like `"/group/items/6/action/url"`
    public init?(from string: String, in data: Data) throws {
        self.init(from: string, in: try JSONSerialization.jsonObject(with: data))
    }
    
    /// `string` is in the format like `"/group/items/6/action/url"`
    public init?(from asdf: String, in json: Any) {
        let string = asdf.hasPrefix("/") ? String(Array(asdf)[1...]) : asdf
        var components = [Component]()
        var json = json
        for key in string.components(separatedBy: "/") where !key.isEmpty {
            if let object = json as? [String: Any], let value = object[key] {
                json = value
                components.append(.key(key))
            } else if let array = json as? [Any], let index = Int(key), index < array.count {
                json = array[index]
                components.append(.index(index))
            } else {
                return nil
            }
        }
        self.components = components
    }
    
    public func appending(_ component: Component) -> JSONPath {
        JSONPath(components: components + [component])
    }
    
    public var debugDescription: String {
        var description = ""
        for component in components {
            switch component {
            case .key(let key):
                if !description.isEmpty {
                    description += "."
                }
                description += key
            case .index(let index):
                description += "[\(index)]"
            }
        }
        return description
    }
}

public class JSONFindPath: NSObject, JSONParserDelegate {
    private let targetPath: JSONPath
    private var currentPath: JSONPath {
        JSONPath(components: containers.compactMap { $0.component })
    }
    
    private var foundPosition: JSONPosition?
    
    private init(path: JSONPath) {
        targetPath = path
        print("target: \(path)")
    }
    
    public static func position(for path: JSONPath, in json: Data) throws -> JSONPosition? {
        let seeker = JSONFindPath(path: path)
        try seeker.parse(json)
        return seeker.foundPosition
    }
    
    private func parse(_ data: Data) throws {
        let parser = JSONParser()
        parser.delegate = self
        try parser.parseData(data)
    }
    
    private struct Container {
        let isObject: Bool
        var currentKey: String?
        var currentIndex: Int = 0
        var component: JSONPath.Component?

        var nextComponent: JSONPath.Component {
            isObject ? .key(currentKey ?? "") : .index(currentIndex)
        }
    }

    private var containers = [Container]()
    
    private func check(_ position: JSONPosition) {
        if let container = containers.last {
            print(currentPath, container.nextComponent)
        }
        if let container = containers.last, targetPath == currentPath.appending(container.nextComponent) {
            foundPosition = position
        } else if targetPath.components.isEmpty {
            foundPosition = position
        }
    }
    
    public func parserDidStartObject(_ parser: JSONParser, position: JSONPosition) {
        guard foundPosition == nil else { return }
        check(position)
        containers.append(Container(isObject: true, component: containers.last?.nextComponent))
    }

    public func parserDidEndObject(_ parser: JSONParser, position: JSONPosition) {
        guard foundPosition == nil else { return }
        containers.removeLast()
        if containers.last?.isObject == false {
            containers[containers.count-1].currentIndex += 1
        } else if containers.last?.isObject == true {
            containers[containers.count-1].currentKey = nil
        }
    }

    public func parserDidStartArray(_ parser: JSONParser, position: JSONPosition) {
        guard foundPosition == nil else { return }
        check(position)
        containers.append(Container(isObject: false, component: containers.last?.nextComponent))
    }

    public func parserDidEndArray(_ parser: JSONParser, position: JSONPosition) {
        guard foundPosition == nil else { return }
        containers.removeLast()
        if containers.last?.isObject == false {
            containers[containers.count-1].currentIndex += 1
        } else if containers.last?.isObject == true {
            containers[containers.count-1].currentKey = nil
        }
    }

    public func parser(_ parser: JSONParser, found string: String, position: JSONPosition) {
        guard foundPosition == nil else { return }
        if containers.last?.isObject ?? false {
            if containers.last?.currentKey == nil {
                containers[containers.count-1].currentKey = string
            } else {
                check(position)
                containers[containers.count-1].currentKey = nil
            }
        } else if containers.last?.isObject == false {
            containers[containers.count-1].currentIndex += 1
        }
    }

    public func parser(_ parser: JSONParser, found number: NSNumber, position: JSONPosition) {
        guard foundPosition == nil else { return }
        check(position)
        if containers.last?.isObject == false {
            containers[containers.count-1].currentIndex += 1
        } else if containers.last?.isObject == true {
            containers[containers.count-1].currentKey = nil
        }
    }

    public func parserFoundTrue(_ parser: JSONParser, position: JSONPosition) {
        guard foundPosition == nil else { return }
        check(position)
        if containers.last?.isObject == false {
            containers[containers.count-1].currentIndex += 1
        } else if containers.last?.isObject == true {
            containers[containers.count-1].currentKey = nil
        }
    }

    public func parserFoundFalse(_ parser: JSONParser, position: JSONPosition) {
        guard foundPosition == nil else { return }
        check(position)
        if containers.last?.isObject == false {
            containers[containers.count-1].currentIndex += 1
        } else if containers.last?.isObject == true {
            containers[containers.count-1].currentKey = nil
        }
    }

    public func parserFoundNull(_ parser: JSONParser, position: JSONPosition) {
        guard foundPosition == nil else { return }
        check(position)
        if containers.last?.isObject == false {
            containers[containers.count-1].currentIndex += 1
        } else if containers.last?.isObject == true {
            containers[containers.count-1].currentKey = nil
        }
    }
}
