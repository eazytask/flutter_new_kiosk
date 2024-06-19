import 'package:flutter/material.dart';

class Employee_Data {
  Color clr;
  String profile;
  String name;
  String id;
  String code;
  Color? tclr;

  Employee_Data(
      this.clr, this.profile, this.name, this.id, this.code, this.tclr);
}

final List<Employee_Data> employeelist = [
  Employee_Data(Color(0xffF5630A), 'assets/Ellipse 2.png', 'Ahsan',
      '0469340198', '#567569834', Colors.white),
  Employee_Data(Color(0xff0ABE52), 'assets/Ellipse 2 (1).png', 'Gul',
      '0469340198', '#567569834', Colors.white),
  Employee_Data(Colors.white, 'assets/Ellipse 2 (1).png', 'Gul', '0469340198',
      '#567569834', Colors.black),
  Employee_Data(Colors.white, 'assets/Ellipse 2 (1).png', 'Gul', '0469340198',
      '#567569834', Colors.black),
  Employee_Data(Colors.white, 'assets/Ellipse 2 (1).png', 'Gul', '0469340198',
      '#567569834', Colors.black),
  Employee_Data(Colors.white, 'assets/Ellipse 2 (1).png', 'Gul', '0469340198',
      '#567569834', Colors.black),
];
