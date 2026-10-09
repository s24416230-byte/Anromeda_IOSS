#import "EscapeEngine.h"
#import "LogManager.h"
#import <dlfcn.h>
#import <sys/stat.h>
#import <dirent.h>
#import <unistd.h>
#import <fcntl.h>
#import <spawn.h>
#import <sys/wait.h>
#import <stdlib.h>
#import <CoreFoundation/CoreFoundation.h>

typedef int64_t (*issue_fn_t)(const char *, uint32_t, pid_t);
typedef int (*consume_fn_t)(int64_t);

static issue_fn_t g_issue = NULL;
static consume_fn_t g_consume = NULL;

static void load_symbols(void) {
    static dispatch_once_t o;
    dispatch_once(&o, ^{
        void *h = dlopen(NULL, RTLD_NOW);
        if (!h) return;
        g_issue   = (issue_fn_t)dlsym(h, "sandbox_extension_issue_file");
        g_consume = (consume_fn_t)dlsym(h, "sandbox_extension_consume");
        if (!g_issue)   g_issue   = (issue_fn_t)dlsym(h, "_sandbox_extension_issue_file");
        if (!g_consume) g_consume = (consume_fn_t)dlsym(h, "_sandbox_extension_consume");
    });
}

@implementation EscapeEngine

+ (NSDictionary *)probeSurface {
    @try {
        load_symbols();
        NSMutableDictionary *r = [NSMutableDictionary dictionary];
        r[@"extension_issue"]   = @(g_issue   != NULL);
        r[@"extension_consume"] = @(g_consume != NULL);

        for (NSString *p in @[@"/var/containers/Shared/SystemGroup",
                              @"/var/mobile/Library/Preferences"]) {
            struct stat st;
            r[[NSString stringWithFormat:@"stat_%@", p]] = @(stat(p.UTF8String, &st) == 0);
        }

        if (g_issue) {
            int64_t t = g_issue("/var/mobile/Library/Preferences", 0x3, getpid());
            r[@"token_issued"] = @(t != -1);
            if (t != -1 && g_consume) {
                r[@"token_consumed"] = @(g_consume(t) == 0);
            }
        }
        return r;
    } @catch (NSException *e) {
        return @{@"error": e.reason ?: @"unknown"};
    }
}

+ (EscapeResult)escapeToPath:(NSString *)path write:(BOOL)write {
    @try {
        load_symbols();
        if (!g_issue || !g_consume) return EscapeResultSymbolMissing;
        int64_t t = g_issue(path.UTF8String, write ? 0x3 : 0x1, getpid());
        if (t == -1) return EscapeResultTokenBlocked;
        return g_consume(t) == 0 ? EscapeResultSuccess : EscapeResultPathDenied;
    } @catch (NSException *e) {
        return EscapeResultPathDenied;
    }
}

+ (NSArray<NSString *> *)enumerateSystemGroupContainers {
    NSMutableArray *res = [NSMutableArray array];
    DIR *d = opendir("/var/containers/Shared/SystemGroup");
    if (!d) return res;
    struct dirent *e;
    while ((e = readdir(d))) {
        if (e->d_name[0] == '.') continue;
        [res addObject:[NSString stringWithFormat:@"%s/%s",
                        "/var/containers/Shared/SystemGroup", e->d_name]];
    }
    closedir(d);
    return res;
}

+ (NSString *)posterBoardContainer {
    for (NSString *c in [self enumerateSystemGroupContainers]) {
        NSDictionary *t = [NSDictionary dictionaryWithContentsOfFile:
            [c stringByAppendingPathComponent:@"Library/SandboxTags.plist"]];
        NSString *o = t[@"SandboxContainerOwner"];
        if ([o hasPrefix:@"systemgroup.com.apple.wallpaper"] ||
            [o hasPrefix:@"systemgroup.com.apple.posterboard"]) {
            return c;
        }
    }
    return nil;
}

+ (NSString *)collectionsDir {
    NSString *c = [self posterBoardContainer];
    return c ? [c stringByAppendingPathComponent:
        @"Library/Application Support/PosterBoard/Collections"] : nil;
}

+ (BOOL)writeData:(NSData *)data toPath:(NSString *)path {
    NSError *e = nil;
    if (![data writeToFile:path options:0 error:&e]) {
        [[LogManager shared] logString:[NSString stringWithFormat:@"write err: %@", e.localizedDescription]];
        return NO;
    }
    return YES;
}

+ (BOOL)writePref:(NSString *)key value:(id)value appID:(NSString *)appID {
    @try {
        CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                 (__bridge CFPropertyListRef)value,
                                 (__bridge CFStringRef)appID);
        CFPreferencesAppSynchronize((__bridge CFStringRef)appID);
        return YES;
    } @catch (NSException *e) {
        return NO;
    }
}

+ (BOOL)writeAnyUserPref:(NSString *)key value:(id)value appID:(NSString *)appID {
    @try {
        CFPreferencesSetValue((__bridge CFStringRef)key,
                              (__bridge CFPropertyListRef)value,
                              (__bridge CFStringRef)appID,
                              kCFPreferencesAnyUser,
                              kCFPreferencesAnyHost);
        CFPreferencesSynchronize((__bridge CFStringRef)appID,
                                 kCFPreferencesAnyUser,
                                 kCFPreferencesAnyHost);
        return YES;
    } @catch (NSException *e) {
        return NO;
    }
}

+ (NSDictionary *)readPrefApp:(NSString *)appID {
    @try {
        CFArrayRef keys = CFPreferencesCopyKeyList((__bridge CFStringRef)appID,
                                                   kCFPreferencesCurrentUser,
                                                   kCFPreferencesCurrentHost);
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        for (CFIndex i = 0; i < CFArrayGetCount(keys); i++) {
            CFStringRef k = CFArrayGetValueAtIndex(keys, i);
            CFPropertyListRef v = CFPreferencesCopyAppValue(k, (__bridge CFStringRef)appID);
            d[(__bridge NSString *)k] = (__bridge id)v;
        }
        CFRelease(keys);
        return d;
    } @catch (NSException *e) {
        return nil;
    }
}

+ (int)spawnBin:(NSString *)path args:(NSArray *)args {
    int argc = (int)args.count + 2;
    char **argv = (char **)malloc(sizeof(char *) * argc);
    argv[0] = (char *)path.UTF8String;
    for (int i = 0; i < args.count; i++) argv[i + 1] = (char *)[args[i] UTF8String];
    argv[argc - 1] = NULL;
    extern char **environ;
    pid_t pid = 0;
    int ret = posix_spawn(&pid, path.UTF8String, NULL, NULL, argv, environ);
    free(argv);
    if (ret != 0) {
        [[LogManager shared] logString:[NSString stringWithFormat:@"spawn '%@' failed: %d", path, ret]];
        return ret;
    }
    int status = 0;
    waitpid(pid, &status, 0);
    [[LogManager shared] logString:[NSString stringWithFormat:@"spawn '%@' exit=%d", path, WEXITSTATUS(status)]];
    return WEXITSTATUS(status);
}

@end