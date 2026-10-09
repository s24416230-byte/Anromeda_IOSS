#import "LogManager.h"

@interface LogManager ()
@end

@implementation LogManager {
    NSMutableArray *_lines;
}

+ (instancetype)shared {
    static LogManager *s;
    static dispatch_once_t o;
    dispatch_once(&o, ^{ s = [LogManager new]; });
    return s;
}

- (instancetype)init {
    self = [super init];
    if (self) _lines = [NSMutableArray array];
    return self;
}

- (NSArray *)lines {
    @synchronized(self) {
        return [_lines copy];
    }
}

- (void)log:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"HH:mm:ss";
    NSString *line = [NSString stringWithFormat:@"[%@] %@", [f stringFromDate:[NSDate date]], msg];

    @synchronized(self) {
        [_lines addObject:line];
        if (_lines.count > 500) [_lines removeObjectAtIndex:0];
    }
    NSLog(@"[femboyplist] %@", line);
}

- (void)logString:(NSString *)message {
    [self log:@"%@", message];
}

- (void)clear {
    @synchronized(self) {
        [_lines removeAllObjects];
    }
}

@end