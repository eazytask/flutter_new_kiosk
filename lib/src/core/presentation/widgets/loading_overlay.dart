

import 'package:kiosk/src/core/constants/app_colors.dart';
import 'package:kiosk/src/core/presentation/widgets/wave_loading.widget.dart';
import 'package:flutter/material.dart';

class ProgressBar {

OverlayEntry? _progressOverlayEntry;

  void show(BuildContext context){
    _progressOverlayEntry = _createdProgressEntry(context);
    Overlay.of(context).insert(_progressOverlayEntry!);
  }

  void hide(){
    if(_progressOverlayEntry?.mounted ?? false){
      _progressOverlayEntry?.remove();
      _progressOverlayEntry == null;
    }
  }

  OverlayEntry _createdProgressEntry(BuildContext context) =>
      OverlayEntry(
          builder: (BuildContext context) =>
              Stack(
                children: <Widget>[
                  Container(
                    color: AppColors.primaryColor.withOpacity(.09),
                  ),
                  const Center(child: CircularProgressIndicator())

                ],

              )
      );



}