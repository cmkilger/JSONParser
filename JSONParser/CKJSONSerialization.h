//
//  CKJSONSerialization.h
//  JSONParser
//
//  Created by Cory Kilger on 4/21/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKJSONSerialization : NSObject

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

@end
