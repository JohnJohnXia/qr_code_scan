//
//  QrCodeScanView.m
//  qr_code_scan
//
//  Created by John Xia on 2020/9/15.
//

#import "QrCodeScanView.h"
#import "ScanView.h"

NSString *const QRScan_METHOD_CHANNEL_NAME = @"plugins.flutter.io/QRScan/methods";

#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self;

@interface QrCodeScanView ()

@property (strong, nonatomic) ScanView *scanContentView;

@property (strong, nonatomic) FlutterMethodChannel *methodChannel;

@end

@implementation QrCodeScanView

- (void)dealloc
{
    NSLog(@"QrCodeScanView release");
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMesenger:(NSObject<FlutterBinaryMessenger> *)messenger
{
    self = [super init];
    if (self) {
        _scanContentView = [[ScanView alloc] initWithFlutterParam:args];
        _scanContentView.backgroundColor = [UIColor greenColor];
        
        WS(weakSelf);
        _methodChannel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"%@_%lld",QRScan_METHOD_CHANNEL_NAME,viewId] binaryMessenger:messenger];
        [_methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [weakSelf handleMethodCall:call result:result];
        }];
    }
    
    return self;
}

- (UIView *)view
{
    return _scanContentView;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result
{
    
}

@end
