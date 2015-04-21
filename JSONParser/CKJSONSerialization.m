//
//  CKJSONSerialization.m
//  JSONParser
//
//  Created by Cory Kilger on 4/21/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#import "CKJSONSerialization.h"
#import "JSONParser.h"

@interface CKJSONSerialization () <JSONParserDelegate>

@property (strong) id root;
@property (strong) NSString * currentKey;
@property (strong) NSMutableArray * containers;

@end

@implementation CKJSONSerialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _containers = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    JSONParser * parser = [[JSONParser alloc] init];
    CKJSONSerialization * treeParser = [[CKJSONSerialization alloc] init];
    parser.delegate = treeParser;
    [parser parseData:data error:error];
    return treeParser.root;
}


#pragma mark - Parser delegate
    
- (void)parserDidStartObject:(JSONParser *)parser {
    NSMutableDictionary * object = [[NSMutableDictionary alloc] init];
    id container = [_containers lastObject];
    if (_currentKey && [container isKindOfClass:[NSMutableDictionary class]]) {
        [container setObject:object forKey:_currentKey];
        _currentKey = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        [container addObject:object];
    } else if (_root == nil) {
        _root = object;
    }
    [_containers addObject:object];
}

- (void)parserDidEndObject:(JSONParser *)parser {
    [_containers removeLastObject];
}

- (void)parserDidStartArray:(JSONParser *)parser {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    id container = [_containers lastObject];
    if (_currentKey && [container isKindOfClass:[NSMutableDictionary class]]) {
        [container setObject:array forKey:_currentKey];
        _currentKey = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        [container addObject:array];
    } else if (_root == nil) {
        _root = array;
    }
    [_containers addObject:array];
}

- (void)parserDidEndArray:(JSONParser *)parser {
    [_containers removeLastObject];
}

- (void)parser:(JSONParser *)parser foundString:(NSString *)string {
    id container = [_containers lastObject];
    if ([container isKindOfClass:[NSMutableDictionary class]]) {
        if (_currentKey) {
            [container setObject:string forKey:_currentKey];
            _currentKey = nil;
        } else {
            _currentKey = string;
        }
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        [container addObject:string];
    } else {
        _root = string;
    }
}

- (void)parser:(JSONParser *)parser foundNumber:(NSNumber *)number {
    id container = [_containers lastObject];
    if ([container isKindOfClass:[NSMutableDictionary class]]) {
        [container setObject:number forKey:_currentKey];
        _currentKey = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        [container addObject:number];
    } else if (_root == nil) {
        _root = number;
    }
}

- (void)parserFoundTrue:(JSONParser *)parser {
    id container = [_containers lastObject];
    if ([container isKindOfClass:[NSMutableDictionary class]]) {
        [container setObject:@(YES) forKey:_currentKey];
        _currentKey = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        [container addObject:@(YES)];
    } else if (_root == nil) {
        _root = @(YES);
    }
}

- (void)parserFoundFalse:(JSONParser *)parser {
    id container = [_containers lastObject];
    if ([container isKindOfClass:[NSMutableDictionary class]]) {
        [container setObject:@(NO) forKey:_currentKey];
        _currentKey = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        [container addObject:@(NO)];
    } else if (_root == nil) {
        _root = @(NO);
    }
}

- (void)parserFoundNull:(JSONParser *)parser {
    id container = [_containers lastObject];
    if ([container isKindOfClass:[NSMutableDictionary class]]) {
        [container setObject:[NSNull null] forKey:_currentKey];
        _currentKey = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        [container addObject:[NSNull null]];
    } else if (_root == nil) {
        _root = [NSNull null];
    }
}

@end
