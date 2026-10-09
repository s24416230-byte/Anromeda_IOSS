#import "PlistWriter.h"
#import "EscapeEngine.h"
#import "LogManager.h"

@implementation PlistWriter

+ (BOOL)write:(NSDictionary *)d toPath:(NSString *)p {
    // Выдаём токены на папку и на сам файл
    [EscapeEngine escapeToPath:[p stringByDeletingLastPathComponent] write:YES];
    [EscapeEngine escapeToPath:p write:YES];

    NSError *e = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:d
        format:NSPropertyListBinaryFormat_v1_0 options:0 error:&e];
    if (!data) {
        [[LogManager shared] logString:[NSString stringWithFormat:@"plist serial error: %@", e]];
        return NO;
    }

    // Пишем НАПРЯМУЮ в p, без .fbptmp и без атомарности
    if (![data writeToFile:p options:0 error:&e]) {
        [[LogManager shared] logString:[NSString stringWithFormat:@"write error: %@", e]];
        return NO;
    }
    return YES;
}

+ (NSDictionary *)read:(NSString *)p {
    [EscapeEngine escapeToPath:p write:NO];
    return [NSDictionary dictionaryWithContentsOfFile:p];
}

+ (BOOL)setKey:(NSString *)k value:(id)v inFile:(NSString *)p {
    NSMutableDictionary *d = [[self read:p] mutableCopy] ?: [NSMutableDictionary new];
    d[k] = v;
    return [self write:d toPath:p];
}

@end