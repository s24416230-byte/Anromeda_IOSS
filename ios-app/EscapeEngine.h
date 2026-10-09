#pragma once
#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, EscapeResult) { EscapeResultSuccess=0, EscapeResultTokenBlocked, EscapeResultPathDenied, EscapeResultSymbolMissing };
@interface EscapeEngine : NSObject
+ (NSDictionary *)probeSurface;
+ (EscapeResult)escapeToPath:(NSString*)path write:(BOOL)write;
+ (NSArray<NSString*>*)enumerateSystemGroupContainers;
+ (NSString*)posterBoardContainer;
+ (NSString*)collectionsDir;
+ (BOOL)writeData:(NSData*)data toPath:(NSString*)path;
+ (BOOL)writePref:(NSString*)key value:(id)value appID:(NSString*)appID;
+ (NSDictionary*)readPrefApp:(NSString*)appID;
+ (int)spawnBin:(NSString*)path args:(NSArray*)args;
@end
