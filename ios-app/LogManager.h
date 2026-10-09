#pragma once
#import <Foundation/Foundation.h>

@interface LogManager : NSObject

+ (instancetype)shared;

@property (nonatomic, readonly) NSArray<NSString *> *lines;

- (void)log:(NSString *)format, ...;
- (void)logString:(NSString *)message;
- (void)clear;

@end