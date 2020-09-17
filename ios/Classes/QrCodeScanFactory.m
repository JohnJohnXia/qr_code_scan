//
//  QrCodeScanFactory.m
//  qr_code_scan
//
//  Created by John Xia on 2020/9/15.
//

#import "QrCodeScanFactory.h"
#import "QrCodeScanView.h"

@implementation QrCodeScanFactory
{
    NSObject<FlutterBinaryMessenger> *_messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
{
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    
    return self;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec
{
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args
{
    return [[QrCodeScanView alloc] initWithFrame:frame viewIdentifier:viewId arguments:args binaryMesenger:_messenger];
}

@end
