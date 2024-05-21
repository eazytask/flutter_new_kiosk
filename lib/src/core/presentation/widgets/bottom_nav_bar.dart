import 'package:flutter/material.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:kiosk/src/feature/employees/presentation/screens/employee.screen.dart';
import 'package:kiosk/src/feature/projects/project.screen.dart';
import 'package:provider/provider.dart';

import '../../../feature/authentication/presentation/providers/auth.provider.dart';
import '../../../feature/client_connection/presentation/providers/client.provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: Colors.black45)),
      child: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        notchMargin: 0.9,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmployeeScreen()), (route) => false);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'assets/png/home-line.png',
                      height: 30,
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Text(
                      'Home',
                      style:
                      TextStyle(fontSize: 13, color: Color(0xff999999)),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmployeeScreen(filterType: 'all')),
                          (route) => false);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'assets/png/user-03.png',
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Text(
                      'All Employees',
                      style:
                      TextStyle(fontSize: 13, color: Color(0xff3498DB)),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
                  context.read<AuthProvider>().logout(context, baseUrl);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'assets/png/Icon.png',
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Text(
                      'Log Out',
                      style:
                      TextStyle(fontSize: 13, color: Color(0xff999999)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
