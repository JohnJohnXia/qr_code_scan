import 'package:flutter/material.dart';
import 'package:qr_code_scan/qr_scan_view.dart';

class ScanFullScreen extends StatefulWidget {
  @override
  _ScanFullScreenState createState() => _ScanFullScreenState();
}

class _ScanFullScreenState extends State<ScanFullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: ScanView(
              isFullScreen: true,
              scanTipText: 'Test',
            ),
          )
      ),
    );
  }
}
