import 'package:kiosk/src/core/presentation/widgets/wave_loading.widget.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WaveLoading(),
    ));
  }
}
