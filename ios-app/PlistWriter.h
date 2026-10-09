#pragma once
#import <Foundation/Foundation.h>
@interface PlistWriter : NSObject
+ (BOOL)write:(NSDictionary *)d toPath:(NSString *)p;
+ (NSDictionary *)read:(NSString *)p;
+ (BOOL)setKey:(NSString *)k value:(id)v inFile:(NSString *)p;
@end
