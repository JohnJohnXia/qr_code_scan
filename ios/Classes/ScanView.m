//
//  ScanView.m
//  qr_code_scan
//
//  Created by John Xia on 2020/9/15.
//

#import "ScanView.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanWeakProxy.h"
#import "QRView.h"

@interface ScanView () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureVideoPreviewLayer  *_captureVideoPreviewLayer;
    
    AVCaptureMetadataOutput     *_captureMetadataOutput;
    
    QRView                      *_qrRectView;
    
    UILabel                     *_qrTipLabel;
    
    CGRect                      _scanAreaRect;
    
    BOOL                        _isFullScreen;
    
    BOOL                        _hideManuallySwitchBtn;
    
    NSString                    *_scanTipText;
}

@property (strong, nonatomic) AVCaptureSession  *captureSession;

@end

@implementation ScanView

- (void)dealloc
{
    NSLog(@"ScanView release");
    [_captureVideoPreviewLayer removeFromSuperlayer];
    _captureVideoPreviewLayer = nil;

    if (_captureSession && _captureSession.isRunning) {
        [_captureSession stopRunning];
    }
    
    _captureSession = nil;
}

- (instancetype)initWithFlutterParam:(id)args
{
    self = [super init];
    if (self) {
        _isFullScreen = [args[@"fullScreen"] boolValue];
        _hideManuallySwitchBtn = [args[@"manuallyHide"] boolValue];
        _scanTipText = args[@"scanTipText"];
        
        [self checkCameraAuthorizationStatus];
    }
    
    return self;
}

#pragma mark - Permisson Method
- (void)checkCameraAuthorizationStatus
{
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    if ([self hasCamera]) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        if (authStatus == AVAuthorizationStatusDenied) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Please allow %@ to access your device's camera in Setting -> Privacy -> Camera",appName]
                                                                             message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                //[self.navigationController popViewControllerAnimated:YES];
            }];
            
            [alertVC addAction:cancelAction];
            [rootVC presentViewController:alertVC animated:YES completion:nil];
        }else {
            [self startSearch];
        }
    }else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"NO Camera" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //[self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alertVC addAction:cancelAction];
        [rootVC presentViewController:alertVC animated:YES completion:nil];
    }
}

- (BOOL)hasCamera
{
    BOOL flag;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        flag = YES;
    } else {
        flag = NO;
    }
    
    return flag;
}

#pragma mark - Scan Method
- (void)startSearch
{
    if (![self hasCamera]) {
        return;
    }
    
    [self setupCameraLayer];
}

- (void)startRunning
{
    if (_captureSession && !_captureSession.isRunning) {
        [_captureSession startRunning];
    }
}

- (void)stopRunning
{
    if (_captureSession && _captureSession.isRunning) {
        [_captureSession stopRunning];
    }
}


#pragma mark - Capture Layer
- (AVCaptureSession *)captureSession
{
    if (!_captureSession) {
        // 创建会话层
        _captureSession = [[AVCaptureSession alloc] init];
        // 设置采集大小
        [_captureSession setSessionPreset:AVCaptureSessionPreset3840x2160];
        // 找到一个合适的采集设备
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // 创建一个输入设备,并将它添加到会话
        AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
        if ([_captureSession canAddInput:captureDeviceInput]) {
            [_captureSession addInput:captureDeviceInput];
        }
        
        // 创建一个输出设备
        _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        if ([_captureSession canAddOutput:_captureMetadataOutput]) {
            [_captureSession addOutput:_captureMetadataOutput];
        }
        
        // 条码类型 AVMetadataObjectTypeQRCode
        _captureMetadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                                      AVMetadataObjectTypeEAN13Code,
                                                      AVMetadataObjectTypeEAN8Code,
                                                      AVMetadataObjectTypeCode128Code];
        
        CGFloat screenHeight = self.frame.size.height;
        CGFloat screenWidth = self.frame.size.width;
        CGRect cropRect;
        
        if (_isFullScreen) {
            CGRect screenRect = [UIScreen mainScreen].bounds;
            
            _qrRectView = [[QRView alloc] initWithFrame:screenRect];
            _qrRectView.transparentArea = CGSizeMake(screenRect.size.width-120, screenRect.size.width-120);
            _qrRectView.backgroundColor = [UIColor clearColor];
            _qrRectView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
            [self addSubview:_qrRectView];
            
            _qrTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, _qrRectView.center.y+_qrRectView.transparentArea.height/2+5, screenWidth-120, 40)];
            _qrTipLabel.textAlignment = NSTextAlignmentCenter;
            _qrTipLabel.numberOfLines = 0;
            _qrTipLabel.font = [UIFont systemFontOfSize:12];
            _qrTipLabel.textColor = [UIColor whiteColor];
            _qrTipLabel.text = @"Please scan the transfer point / merchant identification code";
            _qrTipLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
            [self addSubview:_qrTipLabel];
            
            _qrTipLabel.text = _scanTipText;
            
            if (!_scanTipText || _scanTipText.length == 0) {
                CGRect labelFrame = _qrTipLabel.frame;
                labelFrame.size.height = 0.0;
                
                _qrTipLabel.frame = labelFrame;
            }
            
            cropRect = CGRectMake((screenWidth - _qrRectView.transparentArea.width) / 2,
                                  (screenHeight - _qrRectView.transparentArea.height) / 2,
                                  _qrRectView.transparentArea.width,
                                  _qrRectView.transparentArea.height);
        }else {
            cropRect = CGRectMake(0, 0, screenWidth, screenHeight);
        }
        
        //修正扫描区域
        [_captureMetadataOutput setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                                            cropRect.origin.x / screenWidth,
                                                            cropRect.size.height / screenHeight,
                                                            cropRect.size.width / screenWidth)];
    }
    
    return _captureSession;
}

/**
 *  设置扫描视图
 */
- (void)setupCameraLayer
{
    // 预览视图
    if (_captureVideoPreviewLayer) {
        [_captureVideoPreviewLayer removeFromSuperlayer];
    }
    _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureVideoPreviewLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0].CGColor;
    CGRect frame = self.layer.bounds;
    //frame.origin.y += TPKeyboardScrollView;
    _captureVideoPreviewLayer.frame = frame;
    [self.layer insertSublayer:_captureVideoPreviewLayer atIndex:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _captureVideoPreviewLayer.frame = self.layer.frame;
    
    CGFloat viewHeight = self.frame.size.height;
    CGFloat viewWidth = self.frame.size.width;
    
    CGRect cropRect;
    
    CGFloat videoLayerHeight = _captureVideoPreviewLayer.frame.size.height;
    CGFloat videoLayerWidth = _captureVideoPreviewLayer.frame.size.width;
    
    if (_isFullScreen) {
        _qrRectView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        
        _qrTipLabel.frame = CGRectMake(60, _qrRectView.center.y+_qrRectView.transparentArea.height/2+5, viewWidth-120, 40);
        
        cropRect = CGRectMake((videoLayerWidth - _qrRectView.transparentArea.width) / 2,
                              (videoLayerHeight - _qrRectView.transparentArea.height) / 2,
                              _qrRectView.transparentArea.width,
                              _qrRectView.transparentArea.height);
    }else {
        cropRect = CGRectMake((videoLayerWidth - viewWidth) / 2,
                              0,
                              viewWidth,
                              viewHeight);
                
    }
    
    //修正扫描区域
    [_captureMetadataOutput setRectOfInterest:[self metadataOutputRectOfInterestForRect:cropRect]];
    
    // Start
    if (![self hasCamera]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startRunning];
        });
    });
    
}

- (CGRect)metadataOutputRectOfInterestForRect:(CGRect)cropRect
{
    CGSize size = _captureVideoPreviewLayer.bounds.size;
    CGFloat p1 = size.height/size.width;
    
    CGFloat p2 = 0.0;

    if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        p2 = 1920./1080.;
    }
    else if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPreset352x288]) {
        p2 = 352./288.;
    }
    else if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
        p2 = 1280./720.;
    }
    else if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetiFrame960x540]) {
        p2 = 960./540.;
    }
    else if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetiFrame1280x720]) {
        p2 = 1280./720.;
    }
    else if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetHigh]) {
        p2 = 1920./1080.;
    }
    else if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetMedium]) {
        p2 = 480./360.;
    }
    else if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetLow]) {
        p2 = 192./144.;
    }
    else if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) { // 暂时未查到具体分辨率，但是可以推导出分辨率的比例为4/3
         p2 = 4./3.;
    }
    else if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetInputPriority]) {
        p2 = 1920./1080.;
    }
    else if (@available(iOS 9.0, *)) {
        if ([_captureSession.sessionPreset isEqualToString:AVCaptureSessionPreset3840x2160]) {
            p2 = 3840./2160.;
        }
    } else {
        
    }
    
    CGRect rectOfInterest;
    
    if ([_captureVideoPreviewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize]) {
           rectOfInterest = CGRectMake((cropRect.origin.y)/size.height,(size.width-(cropRect.size.width+cropRect.origin.x))/size.width, cropRect.size.height/size.height,cropRect.size.width/size.width);
    } else if ([_captureVideoPreviewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
           if (p1 < p2) {
               CGFloat fixHeight = size.width * p2;
               CGFloat fixPadding = (fixHeight - size.height)/2;
               rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                           (size.width-(cropRect.size.width+cropRect.origin.x))/size.width,
                                                           cropRect.size.height/fixHeight,
                                                           cropRect.size.width/size.width);
           } else {
               CGFloat fixWidth = size.height * (1/p2);
               CGFloat fixPadding = (fixWidth - size.width)/2;
               rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                           (size.width-(cropRect.size.width+cropRect.origin.x)+fixPadding)/fixWidth,
                                                           cropRect.size.height/size.height,
                                                           cropRect.size.width/fixWidth);
           }
    } else {
           if (p1 > p2) {
               CGFloat fixHeight = size.width * p2;
               CGFloat fixPadding = (fixHeight - size.height)/2;
               rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                           (size.width-(cropRect.size.width+cropRect.origin.x))/size.width,
                                                           cropRect.size.height/fixHeight,
                                                           cropRect.size.width/size.width);
           } else {
               CGFloat fixWidth = size.height * (1/p2);
               CGFloat fixPadding = (fixWidth - size.width)/2;
               rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                           (size.width-(cropRect.size.width+cropRect.origin.x)+fixPadding)/fixWidth,
                                                           cropRect.size.height/size.height,
                                                           cropRect.size.width/fixWidth);
           }
    }
    
    return rectOfInterest;
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *codeValue;
    
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        codeValue = metadataObject.stringValue;
        
        NSLog(@"scan result: %@",codeValue);
        
        if (_resultBlock) {
            _resultBlock(codeValue);
        }
    }
}

@end
