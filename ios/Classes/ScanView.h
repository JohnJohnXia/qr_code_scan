//
//  ScanView.h
//  qr_code_scan
//
//  Created by John Xia on 2020/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ScanResult)(NSString *value);

@interface ScanView : UIView

@property (strong, nonatomic) ScanResult resultBlock;

- (instancetype)initWithFlutterParam:(id)args;

- (void)startRunning;

- (void)stopRunning;


@end

NS_ASSUME_NONNULL_END
