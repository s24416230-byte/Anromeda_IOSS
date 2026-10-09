#import "PlistWriter.h"
#import "EscapeEngine.h"
#import "LogManager.h"
@implementation PlistWriter
+ (BOOL)write:(NSDictionary *)d toPath:(NSString *)p {
    [EscapeEngine escapeToPath:[p stringByDeletingLastPathComponent] write:YES];
    [EscapeEngine escapeToPath:p write:YES];
    NSError *e;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:d
        format:NSPropertyListBinaryFormat_v1_0 options:0 error:&e];
    if (!data) { [[LogManager shared] log:@"plist serial error: %@", e]; return NO; }
    NSString *tmp = [p stringByAppendingString:@".fbptmp"];
    if (![data writeToFile:tmp options:NSDataWritingAtomic error:&e]) {
        [[LogManager shared] log:@"write tmp error: %@", e]; return NO;
    }
    if (rename(tmp.UTF8String, p.UTF8String) != 0)
        return [data writeToFile:p options:NSDataWritingAtomic error:nil];
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
