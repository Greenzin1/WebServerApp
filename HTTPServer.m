#import "HTTPServer.h"
#import <CFNetwork/CFNetwork.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface HTTPServer ()
@property (nonatomic, assign) int serverSocket;
@property (nonatomic, strong) dispatch_source_t acceptSource;
@end

@implementation HTTPServer

- (instancetype)initWithPort:(uint16_t)port documentRoot:(NSString *)root {
    self = [super init];
    if (self) {
        _port = port;
        _documentRoot = [root copy];
        _serverSocket = -1;
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (BOOL)start {
    _serverSocket = socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
    if (_serverSocket < 0) {
        _serverSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (_serverSocket < 0) return NO;
    }

    int reuse = 1;
    setsockopt(_serverSocket, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));

    struct sockaddr_in6 addr6;
    memset(&addr6, 0, sizeof(addr6));
    addr6.sin6_family = AF_INET6;
    addr6.sin6_port = htons(_port);
    addr6.sin6_addr = in6addr_any;

    if (bind(_serverSocket, (struct sockaddr *)&addr6, sizeof(addr6)) < 0) {
        close(_serverSocket);
        _serverSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (_serverSocket < 0) return NO;

        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_port = htons(_port);
        addr.sin_addr.s_addr = INADDR_ANY;

        if (bind(_serverSocket, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
            close(_serverSocket);
            _serverSocket = -1;
            return NO;
        }
    }

    listen(_serverSocket, 5);

    int fd = _serverSocket;
    dispatch_queue_t queue = dispatch_queue_create("httpserver", DISPATCH_QUEUE_SERIAL);
    _acceptSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, queue);

    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_acceptSource, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        struct sockaddr_in6 clientAddr;
        socklen_t addrLen = sizeof(clientAddr);
        int clientFd = accept(strongSelf.serverSocket, (struct sockaddr *)&clientAddr, &addrLen);
        if (clientFd < 0) return;

        dispatch_async(queue, ^{
            [strongSelf handleClient:clientFd];
        });
    });

    dispatch_resume(_acceptSource);
    return YES;
}

- (void)stop {
    if (_acceptSource) {
        dispatch_source_cancel(_acceptSource);
        _acceptSource = nil;
    }
    if (_serverSocket >= 0) {
        close(_serverSocket);
        _serverSocket = -1;
    }
}

- (void)handleClient:(int)clientFd {
    @autoreleasepool {
        char buffer[8192];
        ssize_t bytesRead = read(clientFd, buffer, sizeof(buffer) - 1);
        if (bytesRead <= 0) { close(clientFd); return; }
        buffer[bytesRead] = '\0';

        NSString *request = [NSString stringWithUTF8String:buffer];
        NSArray *lines = [request componentsSeparatedByString:@"\r\n"];
        if (lines.count == 0) { close(clientFd); return; }

        NSArray *parts = [lines[0] componentsSeparatedByString:@" "];
        if (parts.count < 2) { close(clientFd); return; }

        NSString *path = parts[1];
        if ([path isEqualToString:@"/"]) path = @"/index.html";

        NSString *filePath = [_documentRoot stringByAppendingPathComponent:path];
        filePath = [filePath stringByStandardizingPath];

        if (![filePath hasPrefix:_documentRoot]) {
            [self sendResponse:clientFd status:403 body:@"Forbidden"];
            close(clientFd);
            return;
        }

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSString *ext = [filePath pathExtension];
            NSString *contentType = [self contentTypeForExtension:ext];

            NSString *header = [NSString stringWithFormat:
                @"HTTP/1.1 200 OK\r\n"
                @"Content-Type: %@\r\n"
                @"Content-Length: %lu\r\n"
                @"Connection: close\r\n\r\n",
                contentType, (unsigned long)data.length];

            NSData *headerData = [header dataUsingEncoding:NSUTF8StringEncoding];
            write(clientFd, headerData.bytes, headerData.length);
            write(clientFd, data.bytes, data.length);
        } else {
            NSString *body = [NSString stringWithFormat:
                @"<!DOCTYPE html><html><body><h1>404 Not Found</h1><p>%@</p>"
                @"<p>Place your HTML/CSS/JS files in the app's Documents folder via iTunes/Finder.</p>"
                @"</body></html>", path];
            [self sendResponse:clientFd status:404 body:body];
        }

        close(clientFd);
    }
}

- (void)sendResponse:(int)fd status:(int)status body:(NSString *)body {
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSString *header = [NSString stringWithFormat:
        @"HTTP/1.1 %d OK\r\n"
        @"Content-Type: text/html\r\n"
        @"Content-Length: %lu\r\n"
        @"Connection: close\r\n\r\n",
        status, (unsigned long)bodyData.length];
    NSData *headerData = [header dataUsingEncoding:NSUTF8StringEncoding];
    write(fd, headerData.bytes, headerData.length);
    write(fd, bodyData.bytes, bodyData.length);
}

- (NSString *)contentTypeForExtension:(NSString *)ext {
    NSDictionary *types = @{
        @"html": @"text/html",
        @"css": @"text/css",
        @"js": @"application/javascript",
        @"json": @"application/json",
        @"png": @"image/png",
        @"jpg": @"image/jpeg",
        @"jpeg": @"image/jpeg",
        @"gif": @"image/gif",
        @"svg": @"image/svg+xml",
        @"ico": @"image/x-icon",
        @"txt": @"text/plain",
        @"woff": @"font/woff",
        @"woff2": @"font/woff2",
        @"ttf": @"font/ttf",
    };
    return types[[ext lowercaseString]] ?: @"application/octet-stream";
}

@end
