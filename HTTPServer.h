#import <Foundation/Foundation.h>

@interface HTTPServer : NSObject
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, copy) NSString *documentRoot;
- (instancetype)initWithPort:(uint16_t)port documentRoot:(NSString *)root;
- (BOOL)start;
- (void)stop;
@end
