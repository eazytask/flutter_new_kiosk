import 'package:kiosk/src/core/presentation/widgets/wave_loading.widget.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WaveLoading(),
      ),
    );
  }
}
