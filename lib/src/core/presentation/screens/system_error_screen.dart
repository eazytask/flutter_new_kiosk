import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:flutter/material.dart';

class CustomSystemErrorScreen extends StatelessWidget {
  const CustomSystemErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.appUnrecognisedError,
            ),
            const SizedBox(height: 50),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, RouteConstants.loginScreen,
                    ModalRoute.withName('/'),
                );
              },
              child: const Text("Go back"),
            ),
          ],
        ),
      ),
    ));
  }
}
