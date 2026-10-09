#pragma once
#import <Foundation/Foundation.h>

@interface LogManager : NSObject

+ (instancetype)shared;

@property (nonatomic, readonly) NSArray<NSString *> *lines;

- (void)log:(NSString *)format, ...;
- (void)clear;
- (void)logString:(NSString *)message;

@end
