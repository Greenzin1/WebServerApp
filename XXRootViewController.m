#import "XXRootViewController.h"
#import <WebKit/WebKit.h>

@implementation XXRootViewController {
    BOOL _serverStarted;
    uint16_t _port;
    WKWebView *_webView;
}

- (instancetype)initWithServerStarted:(BOOL)started port:(uint16_t)port {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _serverStarted = started;
        _port = port;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    // Status label
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    if (_serverStarted) {
        statusLabel.text = [NSString stringWithFormat:@"Server running on port %d", _port];
        statusLabel.textColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.5 alpha:1.0];
    } else {
        statusLabel.text = @"Server failed to start!";
        statusLabel.textColor = [UIColor redColor];
    }
    [self.view addSubview:statusLabel];

    // WebView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_webView];

    [NSLayoutConstraint activateConstraints:@[
        [statusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [statusLabel.heightAnchor constraintEqualToConstant:30],

        [_webView.topAnchor constraintEqualToAnchor:statusLabel.bottomAnchor constant:8],
        [_webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    if (_serverStarted) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:%d/", _port]];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
