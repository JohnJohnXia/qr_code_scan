#import "QrCodeScanPlugin.h"
#import "QrCodeScanFactory.h"

@implementation QrCodeScanPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
//  FlutterMethodChannel* channel = [FlutterMethodChannel
//                                   methodChannelWithName:@"qr_code_scan"
//                                   binaryMessenger:[registrar messenger]];
//
//
//  QrCodeScanPlugin* instance = [[QrCodeScanPlugin alloc] init];
//  [registrar addMethodCallDelegate:instance channel:channel];
    
    QrCodeScanFactory *factory = [[QrCodeScanFactory alloc] initWithMessenger:registrar.messenger];
    
    [registrar registerViewFactory:factory withId:@"com.flutter_qr_code_scan"];
    
}

//- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
//  if ([@"getPlatformVersion" isEqualToString:call.method]) {
//    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
//  } else {
//    result(FlutterMethodNotImplemented);
//  }
//}

@end
