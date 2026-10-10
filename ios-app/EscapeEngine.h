#pragma once
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EscapeResult) {
    EscapeResultSuccess = 0,
    EscapeResultTokenBlocked,
    EscapeResultPathDenied,
    EscapeResultSymbolMissing
};

@interface EscapeEngine : NSObject

+ (NSDictionary *)probeSurface;

+ (EscapeResult)escapeToPath:(NSString *)path write:(BOOL)write
    NS_SWIFT_NAME(escapeToPath(_:write:));

+ (NSArray<NSString *> *)enumerateSystemGroupContainers;
+ (NSString *)posterBoardContainer;
+ (NSString *)collectionsDir;

+ (BOOL)writeData:(NSData *)data toPath:(NSString *)path;

+ (BOOL)writePref:(NSString *)key value:(id)value appID:(NSString *)appID
    NS_SWIFT_NAME(writePref(_:value:appID:));

+ (NSDictionary *)readPrefApp:(NSString *)appID
    NS_SWIFT_NAME(readPrefApp(_:));

+ (BOOL)writeAnyUserPref:(NSString *)key value:(id)value appID:(NSString *)appID
    NS_SWIFT_NAME(writeAnyUserPref(_:value:appID:));

+ (NSDictionary *)readAnyUserPrefApp:(NSString *)appID
    NS_SWIFT_NAME(readAnyUserPrefApp(_:));

+ (BOOL)deletePref:(NSString *)key appID:(NSString *)appID
    NS_SWIFT_NAME(deletePref(_:appID:));

+ (int)spawnBin:(NSString *)path args:(NSArray *)args
    NS_SWIFT_NAME(spawnBin(_:args:));

@end