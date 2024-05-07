import 'package:kiosk/src/core/presentation/snack_bars/custom.snackbar.dart';
import 'package:kiosk/src/feature/client_connection/presentation/providers/client.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  TextEditingController _customBaseUrlCtrl = TextEditingController();

  // var dbConnFuture;

  @override
  void initState() {
    _customBaseUrlCtrl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _customBaseUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Change Connection'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "Set custom Base URL",
                  // style: Theme.of(context).textTheme.bodyText1,
                  style: TextStyle(
                    // color: Theme.of(context).brightness == Brightness.dark
                    //     ? AppColors.white
                    //     : const Color(0xFF111111),
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
              ),
              TextField(
                controller: _customBaseUrlCtrl,
                // style: Theme.of(context).textTheme.bodyText1!.copyWith(
                //       color: (context.watch<ThemeProvider>().themeMode ==
                //               ThemeMode.dark)
                //           ? AppColors.white
                //           : null,
                //     ),
                style: const TextStyle(
                  // color: Theme.of(context).brightness == Brightness.dark
                  //     ? AppColors.white
                  //     : const Color(0xFF111111),
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  labelText: 'api.eazytask.au',
                  // labelStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                  //       color: (context.watch<ThemeProvider>().themeMode ==
                  //               ThemeMode.dark)
                  //           ? Theme.of(context).textTheme.bodyText2!.color
                  //           : null,
                  //     ),
                  labelStyle: const TextStyle(
                      // color: (context.watch<ThemeProvider>().themeMode ==
                      //         ThemeMode.dark)
                      //     ? AppColors.white
                      //     : AppColors.kLabelColor,
                      fontSize: 17.0),
                  suffixIcon: TextButton(
                    child:  Text(
                      'Save',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      String text = _customBaseUrlCtrl.text;
                      if ((text.isEmpty || text.contains("http"))) {
                        if (!text.contains(RegExp(
                            r'\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b'))) {
                          customSnackBar(
                              context, 'Make sure to enter valid base URL');
                          return;
                        }
                      }
                      context
                          .read<ClientConnectionProvider>()
                          .changeBaseUrl(context, _customBaseUrlCtrl.text);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
