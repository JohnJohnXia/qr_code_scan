import 'package:flutter/material.dart';
import 'package:qr_code_scan/qr_scan_view.dart';

class ScanPartScreen extends StatefulWidget {
  @override
  _ScanPartScreenState createState() => _ScanPartScreenState();
}

class _ScanPartScreenState extends State<ScanPartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: SafeArea(
          child: Container(
            height: 400,
            width: double.infinity,
            child: ScanView(
              isFullScreen: false,
              scanTipText: 'Test',
            ),
          )
      ),
    );
  }
}
