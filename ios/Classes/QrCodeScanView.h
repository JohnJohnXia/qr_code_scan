//
//  QrCodeScanView.h
//  qr_code_scan
//
//  Created by John Xia on 2020/9/15.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface QrCodeScanView : NSObject<FlutterPlatformView>

- (instancetype)initWithFrame:(CGRect)frame
viewIdentifier:(int64_t)viewId
     arguments:(id _Nullable)args
binaryMesenger:(NSObject<FlutterBinaryMessenger> *)messenger;

@end

NS_ASSUME_NONNULL_END
