import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScanView extends StatelessWidget {

  ScanView({
    Key key,
    this.onScanViewCreated,
    this.isFullScreen = true,
    this.scanTipText = 'Please scan the transfer point / merchant identification code',
    this.hideManuallySwitch = false
  }):super(key: key);

  final Function onScanViewCreated;
  final bool     isFullScreen;
  final String   scanTipText;
  final bool     hideManuallySwitch;

  @override
  Widget build(BuildContext context) {
    var param = {
      'fullScreen':isFullScreen,
      'manuallyHide':hideManuallySwitch,
      'scanTipText':scanTipText,
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.flutter_qr_code_scan',
        creationParams: param,
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: (id){
          if (onScanViewCreated != null) {
            onScanViewCreated(id);
          }
        },
      );
    }else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'com.flutter_qr_code_scan',
        creationParams: param,
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: (id){
          if (onScanViewCreated != null) {
            onScanViewCreated(id);
          }
        },
      );
    }

    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin'
    );
  }
}
