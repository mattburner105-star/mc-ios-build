#import "ViewController.h"

static NSString *const MC_URL = @"http://100.126.125.61:3001";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.059f green:0.09f blue:0.165f alpha:1.0f];

    [self createSplashView];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;

    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.navigationDelegate = self;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor colorWithRed:0.059f green:0.09f blue:0.165f alpha:1.0f];
    _webView.hidden = YES;

    if (@available(iOS 11.0, *)) {
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _webView.scrollView.bounces = NO;

    [self.view addSubview:_webView];

    NSURL *url = [NSURL URLWithString:MC_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)createSplashView {
    _splashView = [[UIView alloc] initWithFrame:self.view.bounds];
    _splashView.backgroundColor = [UIColor colorWithRed:0.059f green:0.09f blue:0.165f alpha:1.0f];
    _splashView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"Mission Control";
    _titleLabel.textColor = [UIColor colorWithRed:0.886f green:0.91f blue:0.937f alpha:1.0f];
    _titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightSemibold];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleLabel sizeToFit];
    _titleLabel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 - 30);
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_splashView addSubview:_titleLabel];

    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.text = @"Connecting...";
    _subtitleLabel.textColor = [UIColor colorWithRed:0.58f green:0.639f blue:0.721f alpha:1.0f];
    _subtitleLabel.font = [UIFont systemFontOfSize:14];
    _subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [_subtitleLabel sizeToFit];
    _subtitleLabel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 + 5);
    _subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_splashView addSubview:_subtitleLabel];

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    _activityIndicator.color = [UIColor colorWithRed:0.231f green:0.51f blue:0.965f alpha:1.0f];
    _activityIndicator.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 + 40);
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_activityIndicator startAnimating];
    [_splashView addSubview:_activityIndicator];

    [self.view addSubview:_splashView];
}

- (void)showErrorScreen {
    _webView.hidden = YES;
    _splashView.hidden = NO;

    for (UIView *subview in _splashView.subviews) {
        [subview removeFromSuperview];
    }

    UILabel *errorTitle = [[UILabel alloc] init];
    errorTitle.text = @"Connection Failed";
    errorTitle.textColor = [UIColor colorWithRed:0.973f green:0.427f blue:0.427f alpha:1.0f];
    errorTitle.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
    errorTitle.textAlignment = NSTextAlignmentCenter;
    [errorTitle sizeToFit];
    errorTitle.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 - 50);
    errorTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_splashView addSubview:errorTitle];

    UILabel *errorMsg = [[UILabel alloc] init];
    errorMsg.text = @"Can't reach Mission Control.\nMake sure you're on Tailscale\nand your PC is running.";
    errorMsg.textColor = [UIColor colorWithRed:0.58f green:0.639f blue:0.721f alpha:1.0f];
    errorMsg.font = [UIFont systemFontOfSize:14];
    errorMsg.textAlignment = NSTextAlignmentCenter;
    errorMsg.numberOfLines = 0;
    errorMsg.frame = CGRectMake(40, self.view.bounds.size.height / 2 - 20, self.view.bounds.size.width - 80, 80);
    errorMsg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_splashView addSubview:errorMsg];

    UIButton *retryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [retryBtn setTitle:@"Retry" forState:UIControlStateNormal];
    [retryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    retryBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    retryBtn.backgroundColor = [UIColor colorWithRed:0.231f green:0.51f blue:0.965f alpha:1.0f];
    retryBtn.layer.cornerRadius = 8;
    retryBtn.clipsToBounds = YES;
    retryBtn.frame = CGRectMake(0, 0, 150, 44);
    retryBtn.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 + 70);
    retryBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [retryBtn addTarget:self action:@selector(retryConnection) forControlEvents:UIControlEventTouchUpInside];
    [_splashView addSubview:retryBtn];
}

- (void)retryConnection {
    for (UIView *subview in _splashView.subviews) {
        [subview removeFromSuperview];
    }
    [self createSplashView];

    _webView.hidden = NO;
    NSURL *url = [NSURL URLWithString:MC_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [UIView animateWithDuration:0.3 animations:^{
        self->_splashView.alpha = 0;
    } completion:^(BOOL finished) {
        self->_splashView.hidden = YES;
        self->_webView.hidden = NO;
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showErrorScreen];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showErrorScreen];
}

@end